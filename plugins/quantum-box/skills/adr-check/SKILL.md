---
name: adr-check
description: "Create or verify Tachyon Architecture Decision Records. Use proactively when: (1) the user asks for ADR, (2) a DD or task makes a long-lived architecture decision, (3) a provider/runtime/security/deployment rule is accepted or rejected, or (4) existing ADR consistency must be checked."
---

# ADR Check

## Purpose

Use ADRs for durable decisions and constraints. ADRs explain why a direction was
chosen, which alternatives were rejected, and what future work must respect.
They are not implementation logs.

## When To Create

Create or update an ADR for:

- architectural constraints or platform-wide rules
- provider/runtime selection
- deployment, secret, auth, billing, or observability policy
- cross-context ownership and boundary decisions
- explicit adoption or rejection of a meaningful alternative

Do not create an ADR for:

- a local implementation detail with no lasting consequence
- a task checklist or verification note
- a decision already covered by an existing ADR

## Location And Numbering

ADR files live in:

```text
docs/src/architecture/decisions/ADR-xxxx-short-slug.md
```

Before assigning a number:

```bash
git fetch origin main
find docs/src/architecture/decisions -maxdepth 1 -name 'ADR-*.md' | sort
git ls-tree -r --name-only origin/main docs/src/architecture/decisions | grep 'ADR-'
```

Choose the next number greater than both local and `origin/main` ADR numbers to
avoid collisions when main has moved.

## ADR Shape

Use this structure unless a nearby ADR has a stronger local convention:

```markdown
# ADR-xxxx: Title

## Status

Proposed or Accepted (YYYY-MM-DD)

## Context

## Decision

## Consequences

## Alternatives Considered

## References
```

## Workflow

1. Search existing ADRs for the same decision.
2. If a matching ADR exists, update or reference it instead of creating a
   duplicate.
3. Allocate the next ADR number from local plus `origin/main`.
4. Write the ADR without secrets or environment-specific credential values.
5. Link the ADR from the related taskdoc and DD.
6. Update `docs/SUMMARY.md` if the ADR should be reader-facing.

## Output

Report:

- ADR path and number source
- status
- related taskdoc / DD
- alternatives captured
- follow-up constraints
