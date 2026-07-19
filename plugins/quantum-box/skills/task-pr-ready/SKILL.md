---
name: task-pr-ready
description: "Prepare completed Tachyon work for a Ready PR. Use proactively when: (1) implementation is done and the user asks to create or update a PR, (2) a taskdoc should leave in-progress, (3) PR Ready checks need to be assembled, or (4) the user says PR作って / PR ready / publish this work."
---

# Task PR Ready

## Purpose

Move daily development work from `in-progress` to `completed` at the moment the
pull request becomes Ready. This is the normal taskdoc exit for implementation
work and includes the target component's required version bump. It deliberately
avoids tags and GitHub Release publication.

`completed/` means "implementation is complete and the Ready PR carries the
evidence", not necessarily "merged to main".

## Inputs

- Prefer an explicit taskdoc path.
- If no path is provided, infer from the current branch, changed files, Linear
  ID, or the relevant taskdoc under `docs/src/tasks/in-progress/`.
- If more than one taskdoc belongs to the same delivery, process them together.
- If multiple unrelated taskdocs match, stop and ask for the intended target.

## Safety Gates

- PRs must be Ready (`draft: false`). Do not add `[codex]` to PR titles.
- Do not create git tags or GitHub Releases in this skill.
- Every implementation PR must bump the owning component by at least one patch
  version relative to `origin/main`. A larger semver bump is allowed when the
  change requires it.
- Do not move unfinished, blocked, or intentionally deferred work to
  `completed/`; move it to `todo/` or `backlog/` with a reason instead.
- Determine the base version from `origin/main`, then archive taskdocs under the
  version introduced by the PR, never under the unchanged base version.
- Do not include secrets, tokens, cookies, raw credentials, or expanded secret
  values in taskdocs, PR bodies, DDs, ADRs, logs, or comments.
- Do not commit, push, or create a PR unless the user asked for PR preparation,
  PR creation, publication, or a completion flow that implies publishing.

## Workflow

1. Identify the taskdoc set.
   - Read each target `task.md` and `verification-report.md` if present.
   - Confirm the taskdoc states final scope, checks, browser verification when
     relevant, skipped checks with reasons, and remaining follow-ups.
   - Confirm linked DDs and ADRs are referenced from the taskdoc when they
     exist.

2. Check and bump the component version.
   ```bash
   git fetch origin main
   git show origin/main:apps/tachyon/package.json
   git show origin/main:apps/tachyon-api/Cargo.toml
   ```
   - For Tachyon app/API work, read the matching `version` from `origin/main`
     and bump it by at least one patch version in the PR.
   - If UI and API versions differ, choose the component that owns the delivery
     and state that choice in the PR body.
   - If the owning component is unclear, prefer `apps/tachyon/package.json` for
     Tachyon product work and record the assumption.
   - Update all lockfiles or generated package metadata that mirror the owning
     component version.

3. Archive taskdocs.
   - Move each completed task directory to
     `docs/src/tasks/completed/v<pr-version>/<slug>/`.
   - Update internal links inside moved taskdocs when needed.
   - Update `docs/SUMMARY.md` so links point at the completed location.

4. Prepare PR evidence.
   - Ensure durable docs are updated when the behavior should outlive the
     taskdoc.
   - Link taskdocs, DDs, ADRs, checks, browser screenshots, scenario reports,
     and known skipped checks in the PR body.
   - Include the base version read from `origin/main`, the PR version, and the
     selected bump level.

5. Publish.
   - Prefer the GitHub connector for PR create/update when available.
   - Fall back to `gh pr create` or `gh pr edit` only when connector tools are
     unavailable and local auth is appropriate.
   - Verify the final PR is open, Ready, and targets the expected base branch.

## Output

Report:

- taskdocs archived
- base version source, PR version, and bump level
- DDs / ADRs linked
- checks and browser verification
- PR URL or PR body update status
- remaining follow-ups, if any
