---
name: project-status
description: "Gather project status at session start or when context is needed. Use proactively when: (1) New conversation begins. (2) User asks 'what was I working on?' (3) Before starting a new task. (4) User seems confused about current state."
---

# Project Status

Gather git status, taskdoc lifecycle health, Serena memories, and Docker state.
Do not read every in-progress taskdoc when the directory is large; summarize
counts and route lifecycle cleanup to `taskdoc-audit`.

## Workflow

1. **Git status**
   ```bash
   git status
   git branch --show-current
   git log --oneline -5
   ```

2. **Taskdoc lifecycle**
   ```bash
   for bucket in in-progress todo backlog; do
     if [ -d "docs/src/tasks/$bucket" ]; then
       find "docs/src/tasks/$bucket" -mindepth 1 -maxdepth 1 -type d | wc -l
     else
       echo 0
     fi
   done
   ```
   If `in-progress` has 10 or fewer taskdocs, read their `task.md` files and
   identify current phase. If it has more than 10, list only names and recommend
   `taskdoc-audit`.

3. **Serena memories**
   Use `mcp__serena__list_memories`, read relevant ones (`project_overview`, `development_guidelines`).

4. **Docker status**
   ```bash
   docker ps --format "table {{.Names}}\t{{.Status}}"
   ```

## Output Format

```markdown
## Project Status

**Branch**: `feature/xyz` (3 ahead of main)
**Uncommitted**: 2 modified, 1 untracked

**In-Progress Task**: implement-user-auth
- ✅ Phase 1: Database schema
- 🔄 Phase 2: API endpoints
- 📝 Phase 3: Frontend

**Infrastructure**: ✅ Docker running

**Taskdoc Health**: 8 in-progress, 14 todo, 120 backlog

**Next Steps**: Continue Phase 2 or run `taskdoc-audit`
```
