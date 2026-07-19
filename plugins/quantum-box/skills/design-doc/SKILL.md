---
name: design-doc
description: "Create or update Tachyon Design Documents (DDs). Use proactively when: (1) API, DB, UI workflow, or cross-context behavior is being designed, (2) implementation needs a plan before code, (3) the user asks for DD/design doc, or (4) a taskdoc contains design details that should be separated."
---

# Design Doc

## Purpose

Use a DD to explain the design before implementation. A DD is not a progress
log; it captures the proposed shape of the solution, key alternatives, rollout,
and test strategy. The taskdoc links to it and tracks execution.

## When To Create

Create a DD for:

- new APIs, GraphQL mutations, REST endpoints, or public SDK behavior
- database schema or migration strategy
- cross-context Clean Architecture changes
- UI workflows with meaningful product behavior
- security, authz, billing, deployment, or operational behavior
- changes that need review before implementation

Do not create a DD for:

- small bug fixes with an obvious local fix
- formatting, warning cleanup, or trivial copy changes
- pure verification or investigation logs

## Location

- Delivery-specific DD: `docs/src/tasks/<bucket>/<slug>/design.md`
- Durable service docs: `docs/src/services/<service>/<feature>.md`
- Tachyon product docs: `docs/src/tachyon-apps/<category>/<feature>.md`
- Architecture docs: `docs/src/architecture/<component>.md`

Use `docs/src/template/software-design-document.md` as the starting structure
when a full DD is needed. Keep task-local DDs concise.

## Workflow

1. Confirm scope.
   - Link the Linear issue and taskdoc.
   - State goals and non-goals.
   - Identify affected modules and owners.

2. Write the design.
   - Context and problem statement
   - Options considered
   - Proposed design
   - API / UI / data model changes
   - Migration and rollout plan
   - Security, authz, billing, and operational considerations
   - Test and verification plan
   - Open questions and deferred work

3. Decide whether an ADR is required.
   - If the DD chooses a long-lived architectural rule, provider strategy,
     security constraint, or adoption/rejection decision, create or update an
     ADR with `adr-check`.

4. Link everything.
   - Link the DD from `task.md`.
   - Link related ADRs from the DD.
   - Update `docs/SUMMARY.md` when the DD is durable or reader-facing.

## Output

Report:

- DD path
- linked taskdoc
- linked ADRs, if any
- open questions
- implementation entry points
