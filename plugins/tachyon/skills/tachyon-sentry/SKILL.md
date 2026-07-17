---
name: tachyon-sentry
description: Use Tachyon CLI to inspect and manage Sentry issues through Tachyon's tenant-scoped operations API. Trigger when the user asks to list unresolved Sentry issues, inspect issue details, resolve or assign an issue, verify Sentry connectivity, says "Sentry見て", "Sentryのエラー確認", "tachyon ops sentry", or explicitly wants Sentry access through the Tachyon CLI instead of the Sentry API or UI.
---

# Tachyon Sentry

Use the local `tachyon` CLI for Sentry issue operations.

## Rules

- Use `tachyon ops sentry issues ...`; do not bypass Tachyon with direct Sentry API calls.
- Pass an explicit `--tenant-id` and `--profile` when known. Do not assume the active profile has the correct tenant.
- Add `--json` so results can be parsed and summarized accurately.
- Treat access tokens, auth headers, secret references, DSNs, and credential refresh output as secrets. Never echo them.
- Default to read-only `list` and `view` operations.
- Run `resolve` or `assign` only when the user explicitly requests the mutation and the issue ID is unambiguous. For assignment, require the exact Sentry user ID, username, or email.
- Never use a host token to bypass a tenant-scoped write failure.

## Orientation

Confirm the installed CLI and available subcommands:

```bash
command -v tachyon
tachyon --version
tachyon ops sentry issues --help
```

If authentication or tenant selection is unclear, inspect profiles without exposing credentials:

```bash
tachyon auth list
```

## List Issues

List unresolved issues for a project:

```bash
tachyon ops sentry issues list \
  --project <project_slug_or_id> \
  --query 'is:unresolved' \
  --limit 20 \
  --tenant-id <tenant_id_or_alias> \
  --profile <profile> \
  --json
```

Use the Sentry project slug directly with `--project`; do not rewrite it into the search query.

Report the relevant issue ID or short ID, title, status, count, last-seen time, and permalink. Avoid dumping large raw responses unless requested.

## View an Issue

Fetch one issue by numeric Sentry issue ID:

```bash
tachyon ops sentry issues view <issue_id> \
  --tenant-id <tenant_id_or_alias> \
  --profile <profile> \
  --json
```

Use the numeric `id` returned by `list` when both `id` and `short_id` are present.

## Resolve an Issue

After explicit user confirmation:

```bash
tachyon ops sentry issues resolve <issue_id> \
  --tenant-id <tenant_id_or_alias> \
  --profile <profile> \
  --json
```

Verify the returned status is `resolved`. A read-only OAuth connection is insufficient for mutations; the tenant needs a tenant-scoped write-capable token.

## Assign an Issue

After the user provides the exact assignee:

```bash
tachyon ops sentry issues assign <issue_id> <user_id_username_or_email> \
  --tenant-id <tenant_id_or_alias> \
  --profile <profile> \
  --json
```

Verify the returned `assigned_to` field and report the assignee without exposing other account data.

## Troubleshooting

- `401`: refresh or repair the selected Tachyon auth profile; do not request or print raw tokens.
- `403` on `list` or `view`: verify the tenant's Sentry connection and read scopes.
- `403` or missing-token error on `resolve` or `assign`: the tenant lacks a write-capable token. Do not fall back to another tenant or the host tenant.
- `404`: verify the issue ID, project slug, tenant, and profile. The backend handles a stale organization slug when the token exposes exactly one organization.
- Multiple accessible Sentry organizations: reconnect with an explicit organization instead of guessing.

## Final Response

Keep the result operational:

- State whether the CLI operation succeeded.
- Include the explicit tenant, profile name, project, and command family used.
- For reads, summarize matching issues and whether `view` also succeeded.
- For mutations, state exactly what changed.
- Separate CLI proof from deployment or browser proof when those were not checked.
