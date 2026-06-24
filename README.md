# Quantum Box Agent Packages

Codex and Claude Code plugin marketplace for Quantum Box agent workflows.

## Plugins

- `remote-cdp-browser`: use the private k3s Cloudflare Mesh Chromium CDP gateway from Codex, Claude Code, agent-browser, or Playwright.
- `tachyon-cli`: inspect Tachyon Cloud Apps, build status, deployments, and logs with the local `tachyon` CLI.

## Install

### Codex

```bash
codex plugin marketplace add .agents/plugins/marketplace.json
```

### Claude Code

From Claude Code:

```text
/plugin marketplace add quantum-box/agent-packages
/plugin install remote-cdp-browser@quantum-box-agent-packages
/plugin install tachyon-cli@quantum-box-agent-packages
/reload-plugins
```

For local development:

```bash
claude --plugin-dir ./plugins/remote-cdp-browser
```

The Claude plugins expose `/remote-cdp-browser:remote-cdp-browser` and `/tachyon-cli:tachyon-cli`. The remote CDP browser plugin also adds `remote-browser` to the Bash PATH while it is enabled.
