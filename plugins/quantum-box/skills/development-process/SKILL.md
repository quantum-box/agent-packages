---
name: development-process
description: "Tachyon standard development process. Use proactively before non-trivial Tachyon work, when choosing commands, checks, coding conventions, taskdoc/DD/ADR flow, or when detailed project rules are needed."
---

# Development Process

## Purpose

This skill is the canonical place for Tachyon's detailed development workflow,
basic commands, quality checks, and coding conventions. `AGENTS.md` and
`CLAUDE.md` should stay small and only route agents to skills and durable docs.

When a rule is a long-lived architecture or operations decision, verify or
create an ADR with `adr-check`. When a rule is implementation design for a
specific change, create or update a DD with `design-doc`.

## Non-Negotiable Rules

- Use polite Japanese in conversation. Keep code comments and commit messages in
  English.
- Do not commit, push, create PRs, or change branches unless the user asks.
- Use `mise run` for project tasks. Do not use `just`.
- PRs are Ready PRs by default. Do not add `[codex]` to PR titles.
- Create Linear issues, not GitHub issues. For Codex, use `create-linear-issue`
  when available; otherwise use the Tachyon CLI issue flow.
- Do not create, change, or delete GitHub repositories directly with `gh` or the
  GitHub UI. Manage them through Terraform in `quantum-box/governance`.
- Keep everyday `gh` auth read-only or unauthenticated. Do not store `admin:org`,
  `repo`, `workflow`, or similarly broad scopes.
- Never commit secrets. Keep local credentials in ignored files such as
  `.env.local` or `.secrets.json`.

## Standard Flow

1. **Orient**
   - Run `project-status` when the current branch or task state is unclear.
   - Search related taskdocs, DDs, ADRs, and Linear references before starting.
   - Use `context-loader` for domain-specific work.

2. **Decide task tracking**
   - Use `taskdoc-create` for non-trivial work.
   - Taskdocs are execution logs and evidence, not durable architecture records.
   - Keep only active branch work in `docs/src/tasks/in-progress/`.

3. **Design before implementation**
   - Use `design-doc` for API, DB, UI workflow, cross-context behavior,
     authorization, billing, deployment, or operational behavior changes.
   - Use `adr-check` for long-lived architecture, provider, runtime, security,
     deployment, billing, or operating decisions.
   - Always look for existing ADRs in `docs/src/architecture/decisions/` before
     introducing a new durable rule.

4. **Implement with local patterns**
   - Use `explore` / `find-pattern` before writing unfamiliar code.
   - Use the focused implementation skills when applicable:
     `implement-usecase`, `implement-graphql-resolver`,
     `implement-rest-endpoint`, `implement-component`,
     `implement-repository`, `implement-domain-entity`, `create-migration`,
     `create-scenario-test`, and `create-storybook`.
   - Update the taskdoc with progress, decisions, checks, and evidence as work
     proceeds.

5. **Verify**
   - Run lightweight checks for the changed surface first.
   - Run build, format, lint, type checks, and tests on the host by default,
     scoped to the changed package or Rust crate when practical. macOS Docker
     virtualization overhead is not justified for ordinary validation.
   - Use `docker-ci*` only when the user explicitly requests it, CI parity
     depends on the container image, or the failure is suspected to be
     Docker-specific. Otherwise leave full integration coverage to PR CI.
   - For UI/user-flow changes, use `browser-test` or `playwright-cli`; API-only
     verification is not enough for UI changes.
   - Use real sign-in paths for browser verification unless the user explicitly
     asks for mock auth.
   - Use heavy quality skills (`rust-quality-checker`, `node-quality-checker`,
     `final-quality-gate`) only before PR/merge or when risk justifies it.

6. **Prepare Ready PR**
   - Use `task-pr-ready`.
   - Fetch `origin/main`, confirm the target component version on `origin/main`,
     bump the target component by at least one patch version in every
     implementation PR, archive taskdocs to
     `docs/src/tasks/completed/v<pr-version>/`, update docs navigation if
     needed, and then create a Ready PR.

7. **Release work**
   - Use `task-complete` only for post-merge release work such as changelog,
     release notes, tags, and post-merge durable docs. The ordinary component
     version bump already belongs in the implementation PR.
   - Do not leave normal taskdoc archiving for merge-time cleanup.

8. **Audit lifecycle**
   - Use `taskdoc-audit` when `in-progress` grows or duplicate taskdocs are
     suspected.

## Basic Commands

Run commands from the repository root.

| Purpose | Command | Notes |
| --- | --- | --- |
| Setup | `mise install` then `mise run setup` | Install tools and dependencies. |
| Local Tachyon | `mise run up-local-tachyon` or `mise run uplt` | Preferred daily path: API/UI on host, DB/Redis in Docker. |
| Full Tachyon | `mise run up-tachyon` | Docker-based stack. |
| Library | `mise run up-library` | Library API/UI stack. |
| Infra only | `mise run docker-up` | DB/Redis/migrations/seeds without app processes. |
| Logs | `mise run docker-logs` | Tail Tachyon API/UI logs. |
| Stop | `mise run down` | Stop containers and volumes. |
| Build | `mise run build` or `pnpm run build` | Turbo build. |
| Rust check | `mise run check` | Default lightweight Rust check. |
| Rust format | `mise run fmt` | Use before PR when Rust changed. |
| Full CI | `mise run ci` | Host execution; prefer changed-surface checks when practical. |
| Rust CI | `mise run ci-rust` | Host execution; use only when broad Rust validation is justified. |
| Node lint | `pnpm exec turbo run lint --filter=<pkg>` | Run for changed package. |
| Node types | `pnpm exec turbo run ts --filter=<pkg>` | Run for changed package. |
| Node format | `pnpm exec turbo run format --filter=<pkg>` | Use `pnpm run format:write` to fix format errors. |
| Docker CI | `mise run docker-ci` | Exceptional; explicit request or Docker-specific parity only. |
| Scenario tests | `mise run tachyon-api-scenario-test` | Required when Tachyon API scenarios change. |
| Library scenarios | `mise run library-api-scenario-test` | Required when Library API scenarios change. |
| Library codegen | `mise run codegen-library` | Required after Library GraphQL changes. Tachyon normally does not need codegen. |
| ID generation | `mise run ulid` | Lowercase ULID. |

For DB schema changes, load `create-migration` first and follow its TiDB rules.
For migration/seed execution, use `db-sync`.

## Local URLs And Headers

- Tachyon UI: `http://localhost:${TACHYON_HOST_PORT:-16000}`
- Tachyon dev tenant:
  `http://localhost:${TACHYON_HOST_PORT:-16000}/v1beta/tn_01hjryxysgey07h5jz5wagqj0m`
- Tachyon GraphQL: `http://localhost:${TACHYON_API_HOST_PORT:-50054}/v1/graphql`
- Library UI: `http://localhost:${LIBRARY_HOST_PORT:-5010}`
- Required API headers in local/dev checks:
  - `Authorization: Bearer dummy-token`
  - `x-operator-id: tn_01hjryxysgey07h5jz5wagqj0m`
  - `x-platform-id` optional, `tn_` prefixed
  - `x-user-id` optional; omit only when seed-user fallback is intended

Common test users:

- `test`: `us_01hs2yepy5hw4rz8pdq2wywnwt`, administrator.
- `test2`: `us_01ke1h5471vxsbscp8jd3bramn`, non-admin permission testing.

## Coding Conventions

### TypeScript / React

- Follow Biome formatting: single quotes, trailing commas, minimal semicolons.
- Use Next.js App Router. Prefer Server Components unless client state or
  browser APIs are required.
- Keep GraphQL operations in `.graphql` files and use generated documents.
- Component and story filenames are kebab-case.
- Prefer table/dense operational UI for large datasets.
- Use `neverthrow` `Result<T, E>` for new frontend error handling where practical.
- For Tachyon v1beta pages, wrap with `V1BetaSidebarHeader` and pass breadcrumbs.
- Do not use Next.js Middleware; perform auth checks in pages with
  `authWithCheck()`.

### Rust

- Follow `rustfmt` and clippy. Keep line width around 76.
- Follow Clean Architecture boundaries: `domain`, `usecase`,
  `interface_adapter`, and `handler`.
- Use one public method per usecase. Name usecases with verbs, not nouns, and do
  not add a `Usecase` suffix.
- Include `executor` and `multi_tenancy` in usecase input data and run
  `policy_check` at the start of authorized usecases.
- Add auth actions and policy mappings to
  `scripts/seeds/n1-seed/008-auth-policies.yaml` when introducing new actions.
- Prefer `ok_or_else` when error construction is non-trivial.
- Do not use `SQLX_OFFLINE=true`. Use online SQLx checks and project tasks.
- Do not use `sqlx::query!` macros in tests; use repositories, fixtures, or
  mocks.

### GraphQL / API

- Do not edit generated `schema.graphql` directly.
- Library GraphQL changes require `mise run codegen-library`.
- Keep resolver/controller code thin and route behavior through usecases.

### Docs / YAML / Tests

- Project docs are Japanese. Use PlantUML for diagrams when applicable.
- Structured specs should be YAML with units and currency stated explicitly.
- `examples/` should use real services, not mocks.
- `tests/` may use mocks/stubs for isolation and repeatability.
- Storybook interaction tests are expected for UI components.

## Domain Context Routing

- Auth, policies, and multi-tenancy: use `context-loader` then relevant
  implementation skills. Check existing ADRs and auth policy seeds.
- Payment, billing, NanoDollar, catalog pricing: use `context-loader` and
  linked architecture docs before changing calculations or units.
- LLM/agents/providers: use `context-loader`; provider/runtime rules often need
  ADR review.
- Cloud app routing and txcloud proxy behavior are platform rules. Check ADRs or
  create/update one before changing the operating model.

## Output When Used

When this skill guides a task, report:

- selected taskdoc / DD / ADR state
- implementation skills to use
- lightweight checks planned
- browser/scenario verification plan
- PR Ready or release path, if relevant
