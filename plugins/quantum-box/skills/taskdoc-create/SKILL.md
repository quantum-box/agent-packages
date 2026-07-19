---
name: taskdoc-create
description: "Create or start Tachyon taskdocs. Use proactively when: (1) starting non-trivial implementation, (2) the user asks to make a taskdoc, (3) moving work from backlog/todo to in-progress, or (4) deciding whether DD/ADR is required before implementation."
---

# Taskdoc Create

## Purpose

Create the right task document before implementation starts, without adding
duplicate or stale `in-progress` entries. Taskdocs track execution; DDs and ADRs
hold design and durable decisions.

## When A Taskdoc Is Required

Create or reuse a taskdoc for:

- multi-file changes
- API, GraphQL, REST, DB, authz, billing, deployment, or UI workflow changes
- work tied to a Linear issue
- work that needs browser verification, scenario tests, or rollout notes
- any change likely to need a PR explanation beyond a small local fix

Skip a taskdoc for:

- formatting-only or warning-only cleanup
- tiny one-file fixes with obvious verification
- repeated mechanical checks such as rerunning CI commands

## Workflow

1. Search for existing work first.
   ```bash
   rg -n "<Linear ID|slug|feature keyword>" docs/src/tasks
   find docs/src/tasks/in-progress -mindepth 1 -maxdepth 1 -type d
   ```
   Reuse an existing taskdoc when the Linear ID, slug, or scope matches.

2. Choose lifecycle bucket.
   - `backlog/`: idea or not yet prioritized.
   - `todo/`: prioritized and expected soon.
   - `in-progress/`: implementation starts now in this branch.
   Do not put speculative or paused work in `in-progress`.

3. Decide companion docs.
   - Use `design-doc` when the task changes API, DB, UI workflow,
     cross-context behavior, security, billing, deployment, or operational
     behavior.
   - Use `adr-check` when a long-lived architecture or operating decision is
     made.

4. Create the taskdoc directory.
   - Path: `docs/src/tasks/<bucket>/<slug>/task.md`
   - Verification report: `docs/src/tasks/<bucket>/<slug>/verification-report.md`
   - Screenshots: `docs/src/tasks/<bucket>/<slug>/screenshots/`
   - Slug: kebab-case, preferably including the Linear ID when available.

5. Minimum taskdoc contents.
   - Purpose and background
   - Scope and non-goals
   - Target files or modules
   - Linked Linear issue
   - Linked DD / ADR, if any
   - Implementation phases
   - Test and browser verification plan
   - Completion criteria
   - Risks and deferred work

6. Update navigation.
   - Use `update-docs-summary` when the taskdoc should be discoverable.

## Writing Style（本文は人間が読むための文書）

frontmatterや実行ログはAIが扱うが、taskdoc本文はレビューアや後から経緯を
追う人のための文書として書く。AI向けの網羅的な仕様YAML・テンプレートの
機械的な穴埋め・実装の逐語ログを本文に書かない。仕様の正本が必要ならDDに
分離する。

良い例: `docs/src/tasks/completed/v0.92.8/fix-v1-me-platform-tenant-list/task.md`

- 概要: 現象 → 仕組み → 原因の順に段落で3〜5文。結論を先に書く。
- 原因調査: 確認した事実だけを箇条書きで、エビデンス（再現方法・ID・
  環境・階層構造など）付きで書く。推測と事実を混ぜない。
- 対応: 変更点を番号付きリストで。変更しなかったもの・影響を受けない
  既存挙動も明示する（「〜は無変更」「既存スタブに影響しない」）。
- 検証: 「何を・どこで・どう確認したか」を具体的に書く。スキップした
  確認は「スキップした確認と理由」として必ず理由とセットで残す。
- 残タスク / フォローアップ: 別PR・別リポジトリ・運用作業（デプロイ、
  データ確認）を漏らさず書く。
- 文体: だ・である調または体言止め。ID・パス・コマンド・テーブル名は
  コードスパンにする。冗長な前置きや定型文は書かない。

## Output

Report:

- taskdoc path
- lifecycle bucket
- reused or newly created
- DD / ADR decision
- next implementation step
