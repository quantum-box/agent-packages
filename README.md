# Quantum Box Agent Packages

Codex and Claude Code plugin marketplace for Quantum Box agent workflows.

## Plugins

- `tachyon`: use Tachyon browser, CLI, and Linear workflows from Codex or Claude Code.

## Install

### Codex

```bash
codex plugin marketplace add .agents/plugins/marketplace.json
```

### Claude Code

From Claude Code:

```text
/plugin marketplace add quantum-box/agent-packages
/plugin install tachyon@quantum-box-agent-packages
/reload-plugins
```

For local development:

```bash
claude --plugin-dir ./plugins/tachyon
```

The Claude plugin exposes `/tachyon:tachyon-browser`, `/tachyon:tachyon-cli`, and `/tachyon:tachyon-linear`. It also adds `remote-browser` to the Bash PATH while enabled.
