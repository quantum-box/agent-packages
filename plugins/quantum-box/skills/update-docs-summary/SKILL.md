---
name: update-docs-summary
description: "Update docs/SUMMARY.md when documents move or are added. Use proactively when: (1) new taskdoc/DD/ADR is created, (2) taskdoc moves between backlog/todo/in-progress/completed, (3) task-pr-ready archives taskdocs, or (4) the user asks to update docs index."
---

# Update Docs Summary

Keep `docs/SUMMARY.md` synchronized with document structure.

## File Location

```
docs/SUMMARY.md
```

## Structure

```markdown
# Summary

- [Introduction](README.md)

# Architecture
- [Overview](architecture/overview.md)
- [NanoDollar System](architecture/nanodollar-system.md)

# For Developers
- [Getting Started](for-developers/getting-started.md)

# Tasks
- [In Progress]()
  - [Feature X](tasks/in-progress/feature-x/task.md)
- [Completed]()
  - [v1.0.0]()
    - [Task Y](tasks/completed/v1.0.0/task-y/task.md)
```

## Workflow

### Adding New Taskdoc

1. Find appropriate section in SUMMARY.md
2. Add entry under "In Progress":
```markdown
- [In Progress]()
  - [New Task](tasks/in-progress/new-task/task.md)  # Add this
```

### Completing Taskdoc At PR Ready

1. Determine archive version from `origin/main` using `task-pr-ready`
2. Move entry from "In Progress" to "Completed/vX.X.X":
```markdown
- [Completed]()
  - [v1.0.1]()
    - [Completed Task](tasks/completed/v1.0.1/completed-task/task.md)
```

### Adding DD or ADR

1. Place durable DDs under the relevant service, Tachyon app, or architecture
   section.
2. Place ADRs under the Architecture decisions section.
3. Keep task-local DDs linked from the taskdoc; add them to SUMMARY only when
   they are reader-facing beyond the task.

### Adding Documentation

1. Find or create appropriate section
2. Maintain alphabetical order within sections
3. Use relative paths from docs/src/

## Conventions

- **Indent**: 2 spaces per level
- **Empty parentheses `()`**: For section headers without content
- **Relative paths**: From `docs/src/`
- **Link text**: Use document title or clear description
