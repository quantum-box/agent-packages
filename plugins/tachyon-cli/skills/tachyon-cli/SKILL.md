---
name: tachyon-cli
description: |
  Use Tachyon CLI to inspect Tachyon Cloud Apps, builds, deployments, build logs, auth profiles, and live build status. Trigger when the user asks to check Tachyon CLI logs, Cloud App build status, Tachyon Build failures, app IDs, build IDs, or says "cliでログみて", "tachyon cli", "Cloud Appのログ", or similar.
---

# Tachyon CLI

Use this skill when inspecting Tachyon Platform state through the local `tachyon` CLI.

## Core Rules

- Run the real CLI command when the user asks to check logs or build status.
- Treat tokens, API keys, auth headers, Cloudflare tokens, and generated secrets in logs as secrets.
- Do not echo secret values back to the user. Redact them in summaries.
- Prefer exact app IDs, build IDs, tenant IDs, PR URLs, and Linear/GitHub issue context already provided by the user.
- If the user provides a Cloud App URL or GitHub check URL, extract the app ID / tenant ID from it and start there.
- Do not assume the active profile tenant is correct. Use the explicit tenant from the issue, URL, or app metadata when available.
- If a command refreshes the token, do not mention the token value; it is fine to say the CLI refreshed auth successfully.

## Quick Orientation

Check the installed CLI and auth profile:

```bash
command -v tachyon
tachyon --help
tachyon auth list
```

Cloud Apps live under `compute`:

```bash
tachyon compute --help
tachyon compute apps --help
tachyon compute builds --help
tachyon compute logs --help
```

## Build Status Workflow

1. Identify the target.
   - App ID example: `app_01km2dr0f6hvgj0qvcteyydfbe`
   - Build ID example: `bld_01kqrqg6wa2b1nbarw5efbh0rz`
   - Tenant ID example: `tn_01hjjn348rn3t49zz6hvmfq67p`

2. List builds for the app:

```bash
tachyon compute builds list <app_id_or_name> --tenant-id <tenant_id>
```

3. Fetch latest logs:

```bash
tachyon compute logs <app_id_or_name> --tenant-id <tenant_id>
```

4. Fetch a specific build log:

```bash
tachyon compute logs --build-id <build_id> --tenant-id <tenant_id>
```

5. Follow a running build:

```bash
tachyon compute logs <app_id_or_name> --tenant-id <tenant_id> --follow
```

## What To Report

Summarize high-signal facts:

- Latest build ID, status, branch, commit, and created time.
- Whether the failure mode is still present or fixed.
- Install command path used, especially Yarn v1 vs Yarn v2+ behavior.
- Build command and whether it reached `BUILD State: SUCCEEDED`.
- Deploy command and deployment URL if present.
- Callback result, for example `Build <id> completed successfully`.

Do not paste full raw logs unless the user explicitly asks. Even then, redact secrets.

## Redaction

Before quoting or summarizing logs, redact patterns like:

- `CLOUDFLARE_API_TOKEN=...`
- `TACHYON_AUTH_TOKEN=...`
- `Authorization: Bearer ...`
- `--auth-token ...`
- API keys, client secrets, GitHub tokens, AWS secrets, and signed URLs

Prefer summaries like:

```text
CLOUDFLARE_API_TOKEN=<redacted>
TACHYON_AUTH_TOKEN=<redacted>
```

## Common Cloud Apps Checks

For Vite/Yarn v1 workspace build fixes, look for:

- `Installing Yarn v1 workspace dependencies from <workspace root>`
- `yarn install --frozen-lockfile`
- Absence of `yarn workspaces focus` under Yarn v1
- `npm run build`
- `vite build`
- `pages_build_output_dir = "dist"`
- `wrangler pages deploy dist`
- `Deployment complete!`
- callback `completed successfully`

For old broken Vite paths, look for:

- `yarn workspaces focus` running under Yarn v1
- `.vercel/output/static` being used for Vite output
- missing `dist`
- failed `wrangler pages deploy`

## Final Response

Keep the answer short and operational:

- Say whether the target is actually passing or failing now.
- Include the latest successful or failed build ID.
- Include the exact command family used.
- Call out any residual risk, such as GitHub PR status checks still showing an older failed build even though newer CLI builds succeeded.
