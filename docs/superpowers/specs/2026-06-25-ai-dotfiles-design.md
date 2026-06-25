# AI Dotfiles Source of Truth

This repository will manage AI-related development tooling first: skills, agents, OpenCode, Claude, Codex, and MCP configuration. Broader dotfiles such as shell, Git, Neovim, tmux, Brewfile, and OS setup are intentionally out of scope for the first version.

## Quick path

1. Keep real files in this repository.
2. Run `./bootstrap.sh` from the repository root.
3. Let the script create `$HOME` symlinks for each supported AI tool.
4. Restart OpenCode, Claude, or Codex after changing their config, skills, agents, or MCP files.

## Goals

- Make the repository the source of truth for AI tooling configuration.
- Support macOS, Linux, and WSL2 without committing absolute symlinks.
- Avoid storing tokens, API keys, or machine-specific secrets.
- Keep the first version simple, inspectable, and easy to debug.
- Reserve room for future non-AI dotfiles without implementing them now.

## Non-goals

- Do not manage shell, Git, Neovim, tmux, Homebrew, or full machine setup yet.
- Do not generate tool-specific MCP configs automatically in the first version.
- Do not force one physical MCP config file into multiple tools with incompatible schemas.
- Do not overwrite existing user files without creating backups.

## Repository structure

```txt
dotfiles/
  README.md
  bootstrap.sh
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
      README.md
```

## Architecture decisions

| Area | Decision |
| --- | --- |
| Scope | AI tooling only for version one. |
| Installation | `bootstrap.sh` creates symlinks from `$HOME` into this repository. |
| Safety | Existing files are backed up with timestamps before replacement. |
| Idempotency | Re-running bootstrap should be safe and should not duplicate work. |
| Skills and agents | Keep tool-specific directories, plus `ai/shared` for truly shared material. |
| MCPs | Use a neutral `registry.json` plus per-tool config files. |
| Secrets | Store only env var names or placeholders, never real secret values. |

## Symlink targets

The bootstrap script should create or repair these links:

```txt
ai/shared/skills  -> ~/.agents/skills
ai/opencode/*     -> ~/.config/opencode/*
ai/claude/*       -> ~/.claude/*
ai/codex/*        -> ~/.codex/*
```

MCP files stay in `ai/mcp`. Tool configs may symlink to, include, or reference their matching MCP config depending on what each tool supports.

## Bootstrap behavior

`bootstrap.sh` should support:

```bash
./bootstrap.sh
./bootstrap.sh --dry-run
./bootstrap.sh --force
```

Required behavior:

- Detect macOS, Linux, and WSL2.
- Create required destination directories.
- Validate basic JSON and TOML syntax when local tooling is available.
- Validate `ai/mcp/registry.json` enough to catch malformed entries and obvious secret leaks.
- Create symlinks using paths calculated at runtime.
- Leave correct existing symlinks untouched.
- Backup real files or directories before replacing them.
- Replace incorrect symlinks only when safe, or when `--force` is provided.
- Print a concise summary of what changed.

## MCP registry

`ai/mcp/registry.json` is a neutral inventory, not a generator dependency in version one.

It should document:

- MCP server name.
- Type: `local` or `remote`.
- Command, args, or URL.
- Required environment variables.
- Supported tools: OpenCode, Claude, Codex.
- Notes about setup or permissions.

Tool-specific files remain separate:

```txt
ai/mcp/opencode.json
ai/mcp/claude.json
ai/mcp/codex.json
```

## Secret handling

Allowed:

```json
{ "Authorization": "Bearer {env:GITHUB_TOKEN}" }
```

Not allowed:

```json
{ "Authorization": "Bearer ghp_real_token_here" }
```

Secrets should live outside the repo in 1Password, Keychain, `.env.local`, `.zshrc.local`, or environment variables.

## Review checklist

- [ ] Repository is focused on AI tooling only.
- [ ] Bootstrap uses symlinks, not copies.
- [ ] Existing files are backed up before replacement.
- [ ] MCP config avoids forcing one schema across all tools.
- [ ] No secrets are committed.
- [ ] Future full-dotfiles expansion remains possible.

## Next step

Create the initial repository files: `README.md`, `bootstrap.sh`, `ai/` directories, starter MCP registry, and starter tool config placeholders.
