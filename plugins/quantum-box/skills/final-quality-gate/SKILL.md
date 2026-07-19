---
name: final-quality-gate
description: "Run final host-side quality checks before committing, pushing, or handing off completed Tachyon work. Select build, format, lint, type, and test commands for the changed packages or crates. Use Docker checks only when explicitly requested or when container-specific parity is required."
---

# Final Quality Gate

## Overview

Run build, format, lint, type, and test checks on the host before committing,
pushing, or handing off work. Scope checks to the changed packages or crates
when practical. Do not pay macOS Docker virtualization overhead for ordinary
validation; PR CI remains the integration gate for untouched surfaces.

## When to Use This Skill

Use this skill proactively when:
- **Task completion**: A feature, bug fix, or task is fully implemented
- **Taskdoc phase completion**: A documented phase in the taskdoc is finished
- **Pre-commit**: Code changes are ready to be committed
- **Pre-push**: Local commits are ready to be pushed to remote
- **Handoff readiness**: Work is complete and ready to hand back to the user
- **Clean state requirement**: The codebase should be in a production-ready state

**Key indicators:**
- User mentions being "done" with a task
- All implementation work appears complete
- About to run git commit or git push
- Taskdoc shows a phase is completed
- No more code changes are planned in the immediate session

**Do NOT use this skill:**
- During active development (use rust-quality-checker instead for incremental checks)
- After every small change
- When explicitly skipping CI checks for draft work
- As a reason to run Docker automatically

## Relationship with Other Quality Checks

This skill is **more comprehensive** than an incremental checker:
- Incremental checks: the smallest relevant compile or test command
- `final-quality-gate`: host-side build, format, lint, type, and tests for every changed surface

Run `final-quality-gate` after passing `rust-quality-checker` checks, when ready for final validation.

## Workflow

### 1. Detect Completion Signals

Look for strong indicators that work is complete:
- User explicitly says task is done
- Taskdoc phase marked as complete
- User is about to commit/push
- Implementation appears finished with no TODOs
- User is transitioning to a different task

### 2. Select Host Checks

Inspect the changed files and choose the narrowest complete host-side set:

```bash
# Frontend example
mise exec -- pnpm --dir apps/<package> run format
mise exec -- pnpm --dir apps/<package> run lint
mise exec -- pnpm --dir apps/<package> run ts
mise exec -- pnpm --dir apps/<package> run test
mise exec -- pnpm --dir apps/<package> run build

# Broad Node or Rust checks when justified
mise run ci-node
mise run ci-rust
```

For Rust, prefer crate-scoped `cargo check`, `cargo test`, and `cargo build`
plus `mise run fmt`; broaden to `mise run ci-rust` only when cross-workspace
impact warrants it.

Run `mise run docker-ci`, `docker-ci-rust`, or `docker-ci-node` only when:
- the user explicitly requests Docker validation;
- the change affects Dockerfiles, images, Compose, or container startup; or
- a suspected failure depends on the container environment.

### 3. Analyze Results

**If all checks pass:**
- Confirm success briefly
- Code is ready for commit/push
- No further action needed

**If checks fail:**
- Parse all error outputs
- Group errors by category (Rust errors, TypeScript errors, formatting, linting, tests)
- Prioritize critical issues (compilation errors, failing tests)
- Identify the root cause of each failure

### 4. Auto-Fix All Errors

Systematically fix all identified issues:

#### Rust Issues
- **Compilation errors**: Fix type mismatches, missing imports, syntax errors
- **Test failures**: Update test assertions, fix test setup, address logic bugs
- **Clippy warnings**: Apply suggested improvements, fix code smells
- **Formatting**: Run `cargo fmt` or apply formatting fixes

#### TypeScript/Node Issues
- **Type errors**: Fix type annotations, add missing types, resolve type conflicts
- **Test failures**: Fix broken tests, update snapshots if needed
- **Linting errors**: Apply ESLint/Biome fixes, address code quality issues
- **Formatting**: Run `pnpm run format:write` or apply formatting fixes

#### Cross-cutting Issues
- **Integration test failures**: Fix API contracts, database migrations, environment setup
- **Dependency issues**: Update `Cargo.toml`, `package.json`, resolve conflicts
- **Configuration errors**: Fix `.env` files, config files, CI settings

### 5. Verify Fixes Comprehensively

After applying all fixes:
1. Re-run the selected host checks to verify all issues resolved
2. If new errors appear, analyze and fix them
3. Continue iterating until all checks pass
4. Maximum 3 iteration attempts before asking for user guidance

### 6. Report Final Status

Provide a comprehensive summary:

```
✅ Final Quality Gate: PASSED

Fixed issues:
- 5 Rust compilation errors
- 2 TypeScript type errors
- 1 failing integration test
- 3 formatting issues

All CI checks now pass. Code is ready to commit and push.
```

Or if unable to resolve:

```
⚠️ Final Quality Gate: NEEDS ATTENTION

Successfully fixed:
- 5 Rust compilation errors
- 3 formatting issues

Remaining issues requiring manual review:
- 1 integration test failure (database schema mismatch)
- 1 TypeScript error (complex type inference)

Please review these issues before committing.
```

## Auto-Fix Strategies

### Priority Order
1. **Critical**: Compilation errors, broken builds
2. **High**: Test failures, runtime errors
3. **Medium**: Linting errors, deprecation warnings
4. **Low**: Formatting issues, minor code smells

### Fix Approach
- **Understand first**: Read error messages, understand context
- **Minimal changes**: Fix only what's broken, don't refactor
- **Test incrementally**: Verify each fix before moving to next
- **Document complex fixes**: Explain non-obvious changes
- **Know limits**: If stuck after 2-3 attempts, ask for help

## Best Practices

- **Run proactively**: Don't wait for user to ask, trigger when appropriate
- **Be thorough**: This is the final check, everything must pass
- **Explain clearly**: User needs to understand what was fixed and why
- **Respect boundaries**: If fixes are too complex or risky, involve the user
- **Time awareness**: This is a comprehensive check, it may take time
- **Clean handoff**: Ensure the codebase is in pristine state

## Example Interactions

### Example 1: Task Completion

```
[User completes implementing a new feature]
User: "I'm done implementing the user authentication feature."
Assistant: "I'll run the final quality gate checks to ensure everything is ready for commit."

*Runs the changed package's host-side format, lint, type, test, and build commands*

Found 2 TypeScript errors and 1 formatting issue. Fixing...

*Applies fixes and reruns checks*

✅ Final Quality Gate: PASSED

All CI checks pass. Your authentication feature is ready to commit and push.
```

### Example 2: Pre-Push Validation

```
[User is about to push commits]
User: "Let me push these commits."
Assistant: "Before pushing, let me run comprehensive CI checks."

*Runs the relevant host-side final checks*

✅ Final Quality Gate: PASSED

All checks pass. Safe to push to remote.
```

## Notes

- Host-side validation is the default, especially on macOS
- `mise run ci`, `ci-rust`, and `ci-node` are host-side entry points
- Docker checks are exceptional and must not be selected merely because work is ready for PR
- Use for final validation before commits, pushes, or task handoffs
- Integrates with project's CI tooling for consistency
- Automatically attempts to fix issues to ensure clean handoff
- Part of a quality assurance workflow alongside rust-quality-checker
