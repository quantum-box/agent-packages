---
name: task-complete
description: Finish Tachyon release and post-merge completion work. Use when the user asks to run task-complete, create release notes, tag a Tachyon release, finish release flow, finalize already archived taskdocs, or update durable docs after completed work. For normal Ready PR creation, use task-pr-ready instead.
---

# Task Complete

## Purpose

Finish Tachyon release and post-merge documentation work safely after
implementation work is done. Daily Ready PR preparation belongs to
`task-pr-ready`, including the ordinary component version bump; this skill is
for post-merge release/tag work and final durable documentation updates.
This skill is based on `.claude/commands/task-complete.md`, adapted for Codex
with explicit safety gates around PR state, merge state, version bumps, git
tags, and GitHub Releases.

## Inputs

- Prefer explicit completed taskdoc paths from the user.
- If no path is provided, infer target taskdocs from the current PR, release
  scope, or recent taskdocs under `docs/src/tasks/completed/`.
- If a target taskdoc is still under `docs/src/tasks/in-progress/`, first run
  `task-pr-ready` unless the user explicitly asked for legacy cleanup.
- If more than one taskdoc belongs to the same release, process them together.

## Safety Gates

- Treat `task-complete` as a release completion flow that can include changelog,
  git tag, pushed tag, and GitHub Release when the implementation is already
  merged. Use the version merged by the implementation PR unless an explicit
  additional release bump is requested.
- Treat unmerged implementation work as out of scope for release completion; use
  `task-pr-ready` for Ready PR creation and taskdoc archiving.
- Do not create git tags, push tags, or create GitHub Releases while required
  implementation PRs are still open, dirty, blocked, or unmerged. The ordinary
  app/package version bump must already be present in each implementation PR.
- Do not move daily implementation taskdocs to `docs/src/tasks/completed/` here;
  `task-pr-ready` is the normal archive path at PR Ready time.
- Do not include secrets, tokens, cookies, or credential values in docs,
  changelogs, release notes, or PR comments.
- Do not commit, push, tag, or publish releases unless the user explicitly asked
  for release preparation or publication.

## Workflow

1. Identify target taskdocs.
   - Read the target taskdoc(s) and any verification reports.
   - Confirm the task is genuinely implemented, tested, and PR-ready.

2. Confirm release readiness.
   - Required implementation PRs are merged.
   - Completed taskdocs are already under `docs/src/tasks/completed/<version>/`
     or the user explicitly requested legacy cleanup.
   - Release scope, target version, and tag naming are clear.

3. For release completion:
   - Create or update a durable specification doc when the task created a
     reusable product/platform behavior.
     - Service docs: `docs/src/services/<service>/<feature>.md`
     - Tachyon Apps feature docs: `docs/src/tachyon-apps/<category>/<feature>.md`
     - Developer docs: `docs/src/for-developers/<guide>.md`
     - Architecture docs: `docs/src/architecture/<component>.md`
   - Link the spec from the relevant overview doc and `docs/SUMMARY.md`.
   - Determine the merged version from the relevant package/app metadata.
   - Propose the release tag before editing.
   - Update changelog/release notes, create the tag, push the tag, and create or
     update the GitHub Release. Only add another version bump when explicitly
     requested.
   - When multiple repos are part of one delivery, release them in dependency
     order and note which repos do not need their own release artifact.

4. Validate.
   - Run `git diff --check`.
   - Run docs-specific link/format checks if available.
   - Run any lightweight project check that is relevant to changed docs.

5. Publish.
   - If release completion changed docs, versions, changelog, or release notes,
     commit and push those changes before tagging.

## PR Publication Checklist

Use `task-pr-ready` for ordinary PR creation. This checklist applies only when
release work itself needs a PR.

1. Inspect branch state.
   - Confirm the branch is based on the intended default branch.
   - If the branch contains unrelated local commits, create a clean branch from
     the default branch and cherry-pick only the intended commits.
   - Preserve unrelated user changes.

2. Prepare PR contents.
   - Use a concise title without `[codex]`.
   - Use `draft: false`.
   - Summarize changed files by behavior, not only filenames.
   - Include checks run and any known failing or skipped checks with exact
     reasons.
   - Include release scope, completed taskdocs, checks, and tag/release plan.

3. Publish safely.
   - Prefer the GitHub connector for PR create/update when available.
   - Fall back to `gh pr create` or `gh pr edit` only when connector tools are
     unavailable.
   - For same-repository PRs, omit `maintainer_can_modify` on PR updates if the
     API rejects it.
   - Verify the final PR is `OPEN`, `isDraft=false`, and points at the expected
     head and base branches.

## Completion Report

End with:

- taskdocs processed
- docs/specs changed
- checks run
- commits, tags, releases, or PRs updated
- remaining release-only work
