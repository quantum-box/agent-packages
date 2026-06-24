---
name: remote-cdp-browser
description: Use the Quantum Box k3s Cloudflare Mesh remote Chromium CDP gateway with agent-browser, Playwright, Codex, or Claude Code. Trigger when a task needs a browser reachable from Sakura VPS or another Mesh client, remote CDP automation, temporary browser sessions, named browser sessions, or AgentCore Browser-like session-per-Pod browser control through browser-cdp.intra.quantum-box.com.
---

# Remote CDP Browser

Use this skill to control the k3s-hosted Chromium CDP gateway at:

```text
browser-cdp.intra.quantum-box.com:9222
```

The gateway creates one Chromium Pod per `/sessions/<session_id>` and exposes it as a CDP WebSocket URL. It is intended for Cloudflare Mesh / WARP clients, such as Sakura VPS Claude Code, local Codex, and local automation.

## Rules

- Always pass a `ws://.../sessions/<id>` CDP URL to `agent-browser`.
- Do not pass `http://.../sessions/<id>` to `agent-browser`; its HTTP CDP handling drops the path and falls back to the shared root browser.
- Use the same value for the remote session id and `agent-browser --session` when possible. This avoids local daemon confusion.
- Session ids must match `[A-Za-z0-9._-]{1,96}`.
- Named session state, including cookies, localStorage, and cache, persists while the session Pod is alive.
- Session state is lost when the Pod is deleted by idle timeout, TTL, or explicit DELETE.
- Idle timeout is 30 minutes. Absolute TTL is 6 hours.

## Named Session

Use a named session when the user wants to reconnect to the same browser during a task.

```bash
SESSION_ID="sakura-job-001"

agent-browser \
  --cdp "ws://browser-cdp.intra.quantum-box.com:9222/sessions/${SESSION_ID}" \
  --session "${SESSION_ID}" \
  open https://example.com
```

Continue using the same `SESSION_ID` for subsequent commands:

```bash
agent-browser \
  --cdp "ws://browser-cdp.intra.quantum-box.com:9222/sessions/${SESSION_ID}" \
  --session "${SESSION_ID}" \
  snapshot -i
```

Delete the remote browser when done:

```bash
curl -sS -X DELETE "http://browser-cdp.intra.quantum-box.com:9222/sessions/${SESSION_ID}" | jq .
```

## Temporary Session

Use a temporary session when the user does not care about the session id.

```bash
SESSION_JSON="$(curl -sS -X POST http://browser-cdp.intra.quantum-box.com:9222/sessions)"
SESSION_ID="$(printf '%s' "$SESSION_JSON" | jq -r .session_id)"
CDP_WS="$(printf '%s' "$SESSION_JSON" | jq -r .cdp_ws_url)"

agent-browser \
  --cdp "$CDP_WS" \
  --session "$SESSION_ID" \
  open https://example.com

curl -sS -X DELETE "http://browser-cdp.intra.quantum-box.com:9222/sessions/${SESSION_ID}" | jq .
```

## Wrapper Script

Prefer the bundled helper when doing one-off checks:

```bash
scripts/remote-browser.sh \
  --temporary \
  --cleanup \
  -- open https://example.com
```

Use a named browser:

```bash
scripts/remote-browser.sh \
  --session-id sakura-job-001 \
  -- open https://example.com
```

Create a temporary session and keep it:

```bash
scripts/remote-browser.sh \
  --temporary \
  --keep \
  -- open https://example.com
```

The script prints the remote `session_id` and `cdp_ws_url` to stderr before running `agent-browser`.
Resolve `scripts/remote-browser.sh` relative to this skill directory when the plugin is installed.

## Inspect Sessions

```bash
curl -sS http://browser-cdp.intra.quantum-box.com:9222/readyz
curl -sS http://browser-cdp.intra.quantum-box.com:9222/sessions | jq .
curl -sS http://browser-cdp.intra.quantum-box.com:9222/sessions/<session_id>/json/version | jq .
```

The session list includes `last_access_at`, `idle_seconds`, `idle_timeout_seconds`, and `ttl_seconds`.

## Playwright

For Playwright or direct CDP clients, connect to the WebSocket URL:

```js
import { chromium } from 'playwright';

const browser = await chromium.connectOverCDP(
  'ws://browser-cdp.intra.quantum-box.com:9222/sessions/sakura-job-001',
);
```

## Troubleshooting

- If commands affect the wrong browser, check whether the command used `http://.../sessions/<id>` instead of `ws://.../sessions/<id>`.
- If a session has stale local `agent-browser` state, close it with `agent-browser --session <name> close` and reconnect with the WebSocket CDP URL.
- If the gateway is unreachable, verify the machine is on Cloudflare Mesh / WARP and check `/readyz`.
- If Japanese text appears as boxes, verify the running session Pod uses the Playwright image with `fonts-noto-cjk`; the current gateway template installs it at startup.
- If durable browser profile state is required after Pod deletion, the current gateway does not provide that yet. It needs per-session PVC-backed `--user-data-dir`.
