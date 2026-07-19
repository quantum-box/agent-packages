# Quantum Box Agent Packages

Codex and Claude Code plugin marketplace for Quantum Box agent workflows.

## Plugins

- `tachyon`: use Tachyon browser, CLI, Linear, Sentry, and Slack notification workflows from Codex or Claude Code.
- `quantum-box`: use the canonical Quantum Box engineering workflow for project orientation, taskdocs, design documents, ADRs, focused quality checks, required component version bumps, Ready pull requests, and post-merge releases.

## Install

### Codex

From this repository root:

```bash
codex plugin marketplace add .
codex plugin add tachyon@quantum-box
```

From GitHub:

```bash
codex plugin marketplace add quantum-box/agent-packages
codex plugin add tachyon@quantum-box
codex plugin add quantum-box@quantum-box
```

### Claude Code

From Claude Code:

```text
/plugin marketplace add quantum-box/agent-packages
/plugin install tachyon@quantum-box
/plugin install quantum-box@quantum-box
/reload-plugins
```

For local development:

```bash
claude --plugin-dir ./plugins/tachyon
claude --plugin-dir ./plugins/quantum-box
```

The Claude plugin exposes `/tachyon:tachyon-browser`, `/tachyon:tachyon-cli`, `/tachyon:tachyon-linear`, `/tachyon:tachyon-sentry`, and `/tachyon:tachyon-slack-notify`. It also adds `remote-browser` to the Bash PATH while enabled.

The Quantum Box plugin exposes the shared engineering lifecycle skills under the `quantum-box` namespace. Tachyon-specific operational tools remain in the `tachyon` plugin. `agent-packages` is the source of truth; repository-local copies should only be retained as a generated or compatibility fallback during migration.
