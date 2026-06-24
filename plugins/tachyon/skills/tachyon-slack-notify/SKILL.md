---
name: tachyon-slack-notify
description: Verify and send Slack notifications through the Tachyon CLI. Use when the user asks whether Tachyon CLI Slack notification works, asks to test Slack notification delivery, asks to switch Tachyon tenants for notification testing, or reports CLI tenant selection / `--tenant-id` behavior around `tachyon ops slack send`, `tachyon ops notify send`, or `tachyon switch`.
---

# Tachyon Slack Notify

## Overview

Use the installed `tachyon` CLI to verify real notification delivery through Tachyon's `/v1/chat/send` path. Prefer concrete execution evidence over code-only conclusions.

## Workflow

1. Confirm the CLI version:

```bash
tachyon --version
```

Expect `tachyon 0.5.3` or newer for nested `--tenant-id` support. If older, ask whether to update, or run the repo's release/update workflow if the user explicitly requested it.

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

## Known Tenants From This Workspace

These tenant IDs were useful during the successful verification on 2026-05-01:

```text
tn_01hjryxysgey07h5jz5wagqj0m  Tachyon dev tenant; may return 403 for this profile
tn_01kptmrtgnm746m5mpr78e2esd  THE WAN STANDARD; previously reachable but no Slack destination
tn_01kp2qf7ans8eyzb08b6jr3xf7  cowork; previously reachable but no Slack destination
tn_01knxxebcd2ecv4fjbtzac510p  MOVERENT; previously returned {"accepted": true}
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
