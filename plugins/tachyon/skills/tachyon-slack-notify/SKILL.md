---
name: tachyon-slack-notify
description: Verify and send Slack notifications through the Tachyon CLI, collect thread replies, and answer a reply with a message or an emoji reaction. Use when the user asks whether Tachyon CLI Slack notification works, asks to test Slack notification delivery, asks to wait for or fetch Slack replies to a notification, asks to reply in a notification thread or put a stamp/reaction on a reply so the human sees it was read, asks to switch Tachyon tenants for notification testing, or reports CLI tenant selection / `--tenant-id` behavior around `tachyon ops slack send`, `tachyon ops slack react`, `tachyon ops notify send`, or `tachyon switch`.
---

# Tachyon Slack Notify

## Overview

Use the installed `tachyon` CLI to verify real notification delivery through Tachyon's `/v1/chat/send` path. Prefer concrete execution evidence over code-only conclusions.

Since tachyon-api 0.92.112 (PLT-3042), a notification sent with a `thread_key` records its Slack thread, and replies in that thread can be collected via `GET /v1/chat/replies` or the `wait_slack_reply` MCP tool.

Since tachyon-api 0.92.114 and CLI 0.6.28 (PLT-3087), the loop closes in both directions: the same `thread_key` can be used to post an answer back into the thread, or to put an emoji reaction on the notification or on a specific reply. Without one of those, a human who replied has no way to tell the reply was read.

## Workflow

1. Confirm the CLI version:

```bash
tachyon --version
```

Expect `tachyon 0.5.3` or newer for nested `--tenant-id` support, and `0.6.28` or newer for `--thread-key` and `ops slack react`. If older, ask whether to update, or run the repo's release/update workflow if the user explicitly requested it.

2. List accessible operators when possible:

```bash
tachyon org operators list --json
```

If this fails after switching to a forbidden tenant, recover by switching back to a known accessible tenant.

3. Test the notification with explicit tenant selection:

```bash
tachyon ops slack send --tenant-id <tenant_id_or_alias> --text "Codex test notification from tachyon CLI" --json
```

`ops slack` is an alias for `ops notify`. Both should call `POST /v1/chat/send`.

4. Report the exact API outcome:

- `{"accepted": true}` means Tachyon accepted the notification and dispatched asynchronously.
- `400 No active chat destinations or Slack connection found.` means the tenant is reachable but Slack/Discord destination is not configured.
- `403 PermissionDenied: You do not have permission for this tenant` means the current profile can switch to or name that tenant but cannot send in that tenant.
- Token refresh messages such as `Token refreshed successfully` are normal and are not delivery failures.

## Collecting Thread Replies (PLT-3042)

CLI 0.6.28 supports `--thread-key`, so prefer the CLI. The API form is kept below because the CLI has no `replies` subcommand yet. The bearer token lives in `~/Library/Application Support/tachyon/credentials.json` (`access_token`); treat it as a secret.

1. Send a notification with a stable `thread_key`:

```bash
tachyon ops slack send --tenant-id <tenant_id> --thread-key <stable-key> --text "<message>" --json
```

Equivalent API call:

```bash
curl -s -X POST "https://api.n1.tachy.one/v1/chat/send" \
  -H "Authorization: Bearer $TOKEN" \
  -H "x-operator-id: <tenant_id>" \
  -H "Content-Type: application/json" \
  -d '{"text": "<message>", "thread_key": "<stable-key>"}'
```

`{"accepted":true,"thread_key":"..."}` means dispatch was queued. The thread row is written asynchronously after Slack accepts `chat.postMessage`, so poll step 2 until the thread appears.

2. Fetch replies newer than a cursor:

```bash
curl -s "https://api.n1.tachy.one/v1/chat/replies?thread_key=<stable-key>&after_ts=<last_seen_ts>&timeout_seconds=60" \
  -H "Authorization: Bearer $TOKEN" \
  -H "x-operator-id: <tenant_id>"
```

- Omit `after_ts` on the first call; afterwards pass the last seen reply `ts` to avoid duplicates.
- `timeout_seconds=0` returns immediately; larger values long-poll. Keep `timeout_seconds` at 80 or lower and loop instead: the production gateway kills requests at 90 seconds with `{"error":{"code":"gateway_timeout","deadline_seconds":90}}` (PLT-3064).
- A timeout returns `replies: []` with HTTP 200; `404 Slack notification thread not found` means the thread row does not exist (yet).
- The chat MCP (`/mcp/chat`) exposes the same flow as the `wait_slack_reply` tool with params `thread_key`, `after_ts`, `reply_user_id`, `timeout_seconds`.

## Answering a Reply (PLT-3087)

After collecting a reply, tell the human it was read. Do this whenever the workflow waited on a human — a silent read looks the same as no read at all. A reaction is the cheap acknowledgement; a message is for an actual answer.

Write back into the same thread:

```bash
tachyon ops slack send --tenant-id <tenant_id> --thread-key <stable-key> --text "確認しました" --json
```

Put a reaction on the notification, or on a specific reply:

```bash
tachyon ops slack react --tenant-id <tenant_id> --thread-key <stable-key> --emoji eyes --json
tachyon ops slack react --tenant-id <tenant_id> --thread-key <stable-key> --emoji thumbsup --ts <reply_ts> --json
```

- Omit `--ts` to react to the notification itself; pass the `ts` from `/v1/chat/replies` to react to that reply.
- `--emoji` accepts `eyes`, `:eyes:`, or `thumbsup::skin-tone-2`; the name is normalized server-side.
- `already_reacted: true` is a success, not a failure — re-sending the same acknowledgement is safe and idempotent.
- The API form is `POST /v1/chat/reactions` with `{"thread_key": "...", "emoji": "...", "ts": "..."}`; `ts` is optional.
- Errors: `404 Slack notification thread not found` (unknown `thread_key`), `400 emoji must be a Slack emoji name such as ...` (malformed emoji).

Reactions need the Slack OAuth scope `reactions:write`, added in PLT-3087. **A connection created before that returns `missing_scope`, surfaced as a 400 asking for reconnection** — posting replies still works without reconnecting, only reactions need it. Reconnect the Slack integration for that tenant to fix it.

The chat MCP (`/mcp/chat`) exposes both paths: `post_to_slack` takes an optional `thread_key`, and `add_slack_reaction` takes `thread_key`, `emoji`, and optional `ts`.

## Troubleshooting Dispatch Failures

`accepted:true` does not guarantee delivery — dispatch is async and failures only appear in the ECS logs (`/ecs/tachyon-tachyon-api`, filter pattern `"dispatch"`).

- `not_in_channel`: incoming-webhook posts work, but `chat.postMessage` (required for `thread_key` threading) needs the Tachyon bot to be a channel member. Fix in Slack: channel settings → エージェントとアプリ → add Tachyon.
- `channel_not_found`: the connection metadata's `channel_id` is stale or invalid. Reconnect the Slack integration for that tenant.
- No thread row despite `accepted:true` and no error log: the connection lacks `channel_id` metadata and dispatch fell back to the webhook path; reconnect Slack with a channel selection.

## Known Tenants From This Workspace

These tenant IDs were useful during the successful verification on 2026-05-01:

```text
tn_01hjjn348rn3t49zz6hvmfq67p  Quantum Box platform tenant; full send/replies/react loop verified 2026-08-04 (#tachyon-notification), reactions:write already granted
tn_01hjryxysgey07h5jz5wagqj0m  Tachyon dev tenant; may return 403 for this profile
tn_01kptmrtgnm746m5mpr78e2esd  THE WAN STANDARD; previously reachable but no Slack destination
tn_01kp2qf7ans8eyzb08b6jr3xf7  cowork; previously reachable but no Slack destination
tn_01knxxebcd2ecv4fjbtzac510p  MOVERENT; accepts sends but chat.postMessage fails with channel_not_found (needs Slack reconnect)
```

Do not assume these are always current. Prefer `tachyon org operators list --json` first, then fall back to known IDs when the list command is blocked by the saved tenant context.

## Tenant Switching

Use:

```bash
tachyon switch tachyon
tachyon switch <tenant_id>
```

After testing a tenant that returns `403`, restore the saved tenant to a reachable tenant so future commands do not get stuck:

```bash
tachyon switch tn_01knxxebcd2ecv4fjbtzac510p
```

## Safety

- Treat OAuth tokens and API keys as secrets. Never print or repeat token values.
- Send a short, clearly marked test message.
- If a notification is accepted, ask the user to confirm Slack receipt unless the task only requires API acceptance.
- Do not commit, push, or release CLI changes unless the user explicitly asks for implementation or release work.
