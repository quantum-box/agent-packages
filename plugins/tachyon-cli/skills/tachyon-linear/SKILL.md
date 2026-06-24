---
name: tachyon-linear
description: Use Tachyon CLI to manage Linear issues through Tachyon's project-management integration. Trigger when the user asks to create, list, search, update, assign, prioritize, or move Linear issues with the Tachyon CLI, says "tachyon cliでlinear", "linear issue", "Linear作って", "Linear更新", or asks to avoid GitHub issues and use Linear instead.
---

# Tachyon Linear

Use this skill when operating Linear through the local `tachyon` CLI.

## Rules

- Use the real `tachyon` CLI. Do not use direct Linear API calls or GitHub issues.
- Prefer `tachyon linear issue ...` for Linear-specific work.
- Use `tachyon issue ... --provider linear` only when the user explicitly wants the default project-management abstraction.
- For mutations, confirm the exact title, description, team, status, priority, assignee, and due date unless the user already provided them clearly.
- Always pass an explicit `--tenant-id` when the tenant/operator is known from the task, URL, repo, or user context.
- For Tachyon Apps project work, use team `プラットフォーム事業` when the user has not specified another Linear team.
- Use `--json` when creating, listing, or updating so the result can be parsed and summarized accurately.
- Treat API tokens, auth headers, and credential refresh output as secrets. Do not echo them back.

## Orientation

Check CLI availability and auth before doing live work:

```bash
command -v tachyon
tachyon auth list
tachyon linear --help
tachyon linear issue --help
```

Inspect subcommand options before using unfamiliar fields:

```bash
tachyon linear issue create --help
tachyon linear issue list --help
tachyon linear issue update --help
```

## List Issues

List active Linear issues for a team:

```bash
tachyon linear issue list \
  --team "プラットフォーム事業" \
  --tenant-id <tenant_id_or_alias> \
  --json
```

Include completed or canceled issues when needed:

```bash
tachyon linear issue list \
  --team "プラットフォーム事業" \
  --include-completed \
  --tenant-id <tenant_id_or_alias> \
  --json
```

## Create Issues

Create a Linear issue with an explicit title and Markdown description:

```bash
tachyon linear issue create \
  --team "プラットフォーム事業" \
  --title "<issue title>" \
  --description "<markdown description>" \
  --priority medium \
  --tenant-id <tenant_id_or_alias> \
  --json
```

Use `--skip-if-exists` when creating an idempotent follow-up issue:

```bash
tachyon linear issue create \
  --team "プラットフォーム事業" \
  --title "<issue title>" \
  --description "<markdown description>" \
  --priority medium \
  --skip-if-exists \
  --tenant-id <tenant_id_or_alias> \
  --json
```

Optional fields:

- `--assignee-id <id>` or `--assignee <id>`
- `--label-id <id>` repeated for multiple labels
- `--project <project id or name>`
- `--due-date YYYY-MM-DD`
- `--related-issue-id <id>` repeated for multiple related issues

## Update Issues

Update status, title, assignee, or priority by issue key or id:

```bash
tachyon linear issue update PLT-123 \
  --team "プラットフォーム事業" \
  --status "In Progress" \
  --priority high \
  --tenant-id <tenant_id_or_alias> \
  --json
```

Use provider-specific ids when names are ambiguous:

```bash
tachyon linear issue update PLT-123 \
  --status-id <status_id> \
  --assignee-id <assignee_id> \
  --tenant-id <tenant_id_or_alias> \
  --json
```

## Reporting

Keep the user-facing result short and operational:

- For create: include Linear key/id, title, team, URL if returned, and whether `--skip-if-exists` reused an existing issue.
- For list: include the matching issue keys, titles, statuses, assignees, and dates relevant to the request.
- For update: include the issue key/id and changed fields.
- Mention the exact command family used, for example `tachyon linear issue create`.
