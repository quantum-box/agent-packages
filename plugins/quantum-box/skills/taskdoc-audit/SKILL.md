---
name: taskdoc-audit
description: "Audit Tachyon taskdoc lifecycle health. Use proactively when: (1) in-progress taskdocs are piling up, (2) before creating a new taskdoc while WIP is high, (3) the user asks to clean up taskdocs, or (4) docs/SUMMARY.md may be stale."
---

# Taskdoc Audit

## Purpose

Keep `docs/src/tasks/in-progress/` limited to work that is actively being
implemented now. This skill diagnoses lifecycle drift and proposes small,
reviewable cleanup batches.

## Workflow

1. Count taskdocs by lifecycle bucket.
   ```bash
   for bucket in backlog todo in-progress; do
     if [ -d "docs/src/tasks/$bucket" ]; then
       find "docs/src/tasks/$bucket" -mindepth 1 -maxdepth 1 -type d | wc -l
     else
       echo 0
     fi
   done
   if [ -d docs/src/tasks/completed ]; then
     find docs/src/tasks/completed -mindepth 2 -maxdepth 2 -type d | wc -l
   else
     echo 0
   fi
   ```

2. Compare filesystem and `docs/SUMMARY.md`.
   - Find taskdocs missing from the summary.
   - Find summary links that point to missing taskdocs.
   - Find duplicate summary links.

3. Classify `in-progress` taskdocs.
   - **Active**: current branch/diff/PR clearly references the task.
   - **PR-ready/archive candidate**: final checks and evidence exist, but the
     taskdoc was not moved.
   - **Stalled**: unfinished or blocked; should move to `todo/` or `backlog/`
     with a reason.
   - **Duplicate**: same slug or Linear ID exists elsewhere.
   - **Needs owner decision**: not enough evidence to move safely.

4. Use conservative automatic archive criteria.
   A taskdoc can be proposed as a safe archive candidate only when all are true:
   - `task.md` has at least five completed checklist items.
   - `task.md` has zero open checklist items.
   - `verification-report.md` exists.
   - Status text does not contain `in progress`, `blocked`, `pending`, `保留`,
     `未完了`, or `未確認`.

5. Propose cleanup batches.
   - Do not mass-move taskdocs without explicit user approval.
   - Prefer batches of 5-20 taskdocs.
   - For archive batches, use `task-pr-ready` rules for the destination version.
   - For stalled batches, move to `todo/` or `backlog/` and add a short reason.

## Output

Report:

- lifecycle counts
- summary drift
- duplicate links or duplicate slugs
- active taskdocs
- archive candidates
- stalled/backlog candidates
- recommended next cleanup batch
