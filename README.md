# AI Dotfiles

Source of truth for AI development tooling: skills, agents, OpenCode, Claude, Codex, and MCP configuration.

This repo intentionally starts with AI tooling only. Shell, Git, Neovim, tmux, Homebrew, and full machine bootstrap can be added later.

## Quick start

```bash
./bootstrap.sh --dry-run
./bootstrap.sh
```

Restart OpenCode, Claude, or Codex after changing config, skills, agents, or MCP files.

## Layout

```txt
ai/
  shared/
    skills/
    agents/
    prompts/
  opencode/
    opencode.json
    agents/
    skills/
  claude/
    settings.json
    agents/
    skills/
  codex/
    config.toml
    agents/
    skills/
  mcp/
    registry.json
    opencode.json
    claude.json
    codex.json
```

## Bootstrap behavior

`bootstrap.sh` creates symlinks from `$HOME` back into this repo.

If a destination already exists as a real file or directory, it is moved into `.backups/<timestamp>/` before the symlink is created.

If a destination exists as an incorrect symlink, rerun with:

```bash
./bootstrap.sh --force
```

## Secrets

Do not commit tokens, API keys, or bearer values.

Use environment variable references in config files and keep actual values in 1Password, Keychain, `.env.local`, `.zshrc.local`, or exported shell variables.

## What is intentionally excluded

Runtime state, caches, histories, sessions, auth files, SQLite databases, and backups are not part of this repo.

Examples:

- Claude `projects/`, `sessions/`, `paste-cache/`, `file-history/`, `backups/`
- Codex `auth.json`, `history.jsonl`, SQLite files, sessions, cache, app binaries
- OpenCode `node_modules/`, logs, profile history, local account files

## MCPs

`ai/mcp/registry.json` is the neutral inventory. Tool-specific MCP mirrors live next to it:

- `ai/mcp/opencode.json`
- `ai/mcp/claude.json`
- `ai/mcp/codex.json`

The Stitch API key was intentionally replaced with an environment variable placeholder. Set `GOOGLE_STITCH_API_KEY` outside the repo before using that MCP.
