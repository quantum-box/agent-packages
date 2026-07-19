---
name: resume-task
description: 進行中または再開対象のTachyon taskdocを絞り込んで現状を把握する
---

対象 taskdoc を絞り込んで現状を把握する。`docs/src/tasks/in-progress`
を全件読む運用は避け、件数が多い場合は `taskdoc-audit` に切り替える。

## 手順

1. 明示された taskdoc path、Linear ID、branch 名、差分ファイルから再開対象を推定する
2. 候補が不明な場合は `docs/src/tasks/in-progress/` と `docs/src/tasks/todo/`
   の名前だけを一覧し、必要ならユーザーに対象を確認する
3. `in-progress` が 10 件を超える場合は全件読まず、`taskdoc-audit` を提案する
4. 対象 taskdoc について以下を把握・報告する:
   - タスクの目的と背景
   - 現在のフェーズと進捗状況（✅完了 / 🔄進行中 / 📝未着手）
   - 次にやるべきこと
   - 関連ファイルや注意点
   - 関連 DD / ADR / PR / Linear issue
5. taskdocが存在しない場合は「再開対象の taskdoc は見つかりません」と伝える

## 報告形式

```
## 現在のタスク: [タスク名]

**目的**: ...

**進捗状況**:
- Phase 1: ✅ 完了
- Phase 2: 🔄 進行中 ← 現在ここ
- Phase 3: 📝 未着手

**次のアクション**:
1. ...
2. ...

**関連ファイル**:
- `path/to/file.rs`

**関連ドキュメント**:
- DD: `docs/src/tasks/in-progress/.../design.md`
- ADR: `docs/src/architecture/decisions/ADR-xxxx-...md`
```

複数の taskdoc が同じ delivery に属する場合はまとめて報告する。無関係な
taskdoc が複数見つかった場合は、勝手に全件再開せず対象を確認する。
