# AI Dotfiles Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the initial AI-focused dotfiles repository with safe symlink bootstrap, per-tool AI config directories, and MCP registry/config placeholders.

**Architecture:** The repository owns real files under `ai/`. `bootstrap.sh` creates or repairs symlinks from `$HOME` into the repo, backing up pre-existing real files or directories before replacement. MCPs use a neutral registry plus per-tool config files to avoid forcing incompatible schemas across OpenCode, Claude, and Codex.

**Tech Stack:** POSIX shell with Bash, JSON config files, TOML config file, macOS/Linux/WSL2 filesystem conventions.

---

## File map

| Path | Responsibility |
| --- | --- |
| `README.md` | Explain purpose, quick start, layout, secret policy, and restart expectations. |
| `bootstrap.sh` | Idempotently create `$HOME` directories, validate lightweight config files, backup conflicts, and create symlinks. |
| `ai/shared/skills/.gitkeep` | Preserve shared skills directory. |
| `ai/shared/agents/.gitkeep` | Preserve shared agents directory. |
| `ai/shared/prompts/.gitkeep` | Preserve shared prompts directory. |
| `ai/opencode/opencode.json` | Starter OpenCode config with schema and MCP placeholder. |
| `ai/opencode/agents/.gitkeep` | Preserve OpenCode agents directory. |
| `ai/opencode/skills/.gitkeep` | Preserve OpenCode skills directory. |
| `ai/claude/settings.json` | Starter Claude settings placeholder. |
| `ai/claude/agents/.gitkeep` | Preserve Claude agents directory. |
| `ai/claude/skills/.gitkeep` | Preserve Claude skills directory. |
| `ai/codex/config.toml` | Starter Codex config placeholder. |
| `ai/codex/agents/.gitkeep` | Preserve Codex agents directory. |
| `ai/codex/skills/.gitkeep` | Preserve Codex skills directory. |
| `ai/mcp/registry.json` | Neutral MCP inventory and secret-safe metadata. |
| `ai/mcp/opencode.json` | OpenCode MCP config placeholder. |
| `ai/mcp/claude.json` | Claude MCP config placeholder. |
| `ai/mcp/codex.json` | Codex MCP config placeholder. |
| `ai/mcp/README.md` | How to add MCPs and where secrets live. |

## Task 1: Create repository skeleton

**Files:**
- Create: `ai/shared/skills/.gitkeep`
- Create: `ai/shared/agents/.gitkeep`
- Create: `ai/shared/prompts/.gitkeep`
- Create: `ai/opencode/agents/.gitkeep`
- Create: `ai/opencode/skills/.gitkeep`
- Create: `ai/claude/agents/.gitkeep`
- Create: `ai/claude/skills/.gitkeep`
- Create: `ai/codex/agents/.gitkeep`
- Create: `ai/codex/skills/.gitkeep`

- [ ] **Step 1: Create directory tree**

Run:

```bash
mkdir -p ai/shared/{skills,agents,prompts} ai/opencode/{agents,skills} ai/claude/{agents,skills} ai/codex/{agents,skills} ai/mcp
```

Expected: command exits successfully and creates the tree.

- [ ] **Step 2: Preserve empty directories**

Run:

```bash
touch ai/shared/skills/.gitkeep ai/shared/agents/.gitkeep ai/shared/prompts/.gitkeep ai/opencode/agents/.gitkeep ai/opencode/skills/.gitkeep ai/claude/agents/.gitkeep ai/claude/skills/.gitkeep ai/codex/agents/.gitkeep ai/codex/skills/.gitkeep
```

Expected: command exits successfully.

- [ ] **Step 3: Verify skeleton**

Run:

```bash
test -d ai/shared/skills && test -d ai/opencode/agents && test -d ai/claude/skills && test -d ai/codex/agents && test -d ai/mcp
```

Expected: command exits with status `0`.

## Task 2: Add starter tool configs

**Files:**
- Create: `ai/opencode/opencode.json`
- Create: `ai/claude/settings.json`
- Create: `ai/codex/config.toml`

- [ ] **Step 1: Create OpenCode config**

Write `ai/opencode/opencode.json`:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {}
}
```

- [ ] **Step 2: Create Claude settings placeholder**

Write `ai/claude/settings.json`:

```json
{
  "mcpServers": {}
}
```

- [ ] **Step 3: Create Codex config placeholder**

Write `ai/codex/config.toml`:

```toml
# Codex configuration managed by this dotfiles repository.
# Add Codex-specific settings here when needed.
```

- [ ] **Step 4: Validate JSON files**

Run:

```bash
python3 -m json.tool ai/opencode/opencode.json >/dev/null && python3 -m json.tool ai/claude/settings.json >/dev/null
```

Expected: command exits with status `0`.

## Task 3: Add MCP inventory and placeholders

**Files:**
- Create: `ai/mcp/registry.json`
- Create: `ai/mcp/opencode.json`
- Create: `ai/mcp/claude.json`
- Create: `ai/mcp/codex.json`
- Create: `ai/mcp/README.md`

- [ ] **Step 1: Create neutral MCP registry**

Write `ai/mcp/registry.json`:

```json
{
  "servers": []
}
```

- [ ] **Step 2: Create OpenCode MCP config placeholder**

Write `ai/mcp/opencode.json`:

```json
{
  "mcp": {}
}
```

- [ ] **Step 3: Create Claude MCP config placeholder**

Write `ai/mcp/claude.json`:

```json
{
  "mcpServers": {}
}
```

- [ ] **Step 4: Create Codex MCP config placeholder**

Write `ai/mcp/codex.json`:

```json
{
  "mcpServers": {}
}
```

- [ ] **Step 5: Document MCP workflow**

Write `ai/mcp/README.md`:

```markdown
# MCP Configuration

This directory tracks MCP intent and tool-specific MCP configuration.

## Files

| File | Purpose |
| --- | --- |
| `registry.json` | Neutral inventory of MCP servers and required environment variables. |
| `opencode.json` | OpenCode-specific MCP shape. |
| `claude.json` | Claude-specific MCP shape. |
| `codex.json` | Codex-specific MCP shape. |

## Secret policy

Never commit tokens, API keys, or bearer values.

Use environment variable references instead, for example:

```json
{ "Authorization": "Bearer {env:GITHUB_TOKEN}" }
```

Keep real secrets in 1Password, Keychain, `.env.local`, `.zshrc.local`, or exported environment variables.
```

- [ ] **Step 6: Validate MCP JSON files**

Run:

```bash
python3 -m json.tool ai/mcp/registry.json >/dev/null && python3 -m json.tool ai/mcp/opencode.json >/dev/null && python3 -m json.tool ai/mcp/claude.json >/dev/null && python3 -m json.tool ai/mcp/codex.json >/dev/null
```

Expected: command exits with status `0`.

## Task 4: Implement bootstrap script

**Files:**
- Create: `bootstrap.sh`

- [ ] **Step 1: Write bootstrap script**

Write `bootstrap.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=0
FORCE=0

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    --force) FORCE=1 ;;
    -h|--help)
      cat <<'HELP'
Usage: ./bootstrap.sh [--dry-run] [--force]

Creates symlinks from this repository into AI tool config locations.

Options:
  --dry-run  Print actions without changing files
  --force    Replace incorrect existing symlinks
HELP
      exit 0
      ;;
    *)
      echo "Unknown argument: $arg" >&2
      exit 1
      ;;
  esac
done

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$ROOT_DIR/.backups/$(date +%Y%m%d-%H%M%S)"

log() {
  printf '%s\n' "$*"
}

run() {
  if [ "$DRY_RUN" -eq 1 ]; then
    log "DRY-RUN: $*"
  else
    "$@"
  fi
}

detect_platform() {
  local kernel
  kernel="$(uname -s)"

  if [ "$kernel" = "Darwin" ]; then
    echo "macos"
    return
  fi

  if [ "$kernel" = "Linux" ]; then
    if grep -qi microsoft /proc/version 2>/dev/null; then
      echo "wsl2"
    else
      echo "linux"
    fi
    return
  fi

  echo "unknown"
}

backup_path() {
  local target="$1"
  local relative
  relative="${target#$HOME/}"
  local destination="$BACKUP_DIR/$relative"

  run mkdir -p "$(dirname "$destination")"
  run mv "$target" "$destination"
  log "Backed up $target -> $destination"
}

link_path() {
  local source="$1"
  local target="$2"

  if [ ! -e "$source" ] && [ ! -d "$source" ]; then
    echo "Missing source: $source" >&2
    exit 1
  fi

  run mkdir -p "$(dirname "$target")"

  if [ -L "$target" ]; then
    local current
    current="$(readlink "$target")"
    if [ "$current" = "$source" ]; then
      log "OK: $target -> $source"
      return
    fi

    if [ "$FORCE" -eq 1 ]; then
      run rm "$target"
    else
      echo "Refusing to replace incorrect symlink without --force: $target -> $current" >&2
      exit 1
    fi
  elif [ -e "$target" ] || [ -d "$target" ]; then
    backup_path "$target"
  fi

  run ln -s "$source" "$target"
  log "Linked: $target -> $source"
}

validate_json() {
  local file="$1"
  if command -v python3 >/dev/null 2>&1; then
    python3 -m json.tool "$file" >/dev/null
    log "Valid JSON: $file"
  else
    log "Skipped JSON validation, python3 not found: $file"
  fi
}

validate_mcp_registry() {
  local file="$ROOT_DIR/ai/mcp/registry.json"
  validate_json "$file"

  if grep -Eiq '(ghp_|sk-[A-Za-z0-9]|api[_-]?key["'"']?\s*[:=]\s*["'"'][^"'"']+|bearer\s+[A-Za-z0-9._-]{20,})' "$file"; then
    echo "Potential secret detected in $file" >&2
    exit 1
  fi

  log "No obvious secrets detected in MCP registry"
}

main() {
  local platform
  platform="$(detect_platform)"
  log "Platform: $platform"
  log "Repository: $ROOT_DIR"

  validate_json "$ROOT_DIR/ai/opencode/opencode.json"
  validate_json "$ROOT_DIR/ai/claude/settings.json"
  validate_json "$ROOT_DIR/ai/mcp/opencode.json"
  validate_json "$ROOT_DIR/ai/mcp/claude.json"
  validate_json "$ROOT_DIR/ai/mcp/codex.json"
  validate_mcp_registry

  link_path "$ROOT_DIR/ai/shared/skills" "$HOME/.agents/skills"
  link_path "$ROOT_DIR/ai/opencode/opencode.json" "$HOME/.config/opencode/opencode.json"
  link_path "$ROOT_DIR/ai/opencode/agents" "$HOME/.config/opencode/agents"
  link_path "$ROOT_DIR/ai/opencode/skills" "$HOME/.config/opencode/skills"
  link_path "$ROOT_DIR/ai/claude/settings.json" "$HOME/.claude/settings.json"
  link_path "$ROOT_DIR/ai/claude/agents" "$HOME/.claude/agents"
  link_path "$ROOT_DIR/ai/claude/skills" "$HOME/.claude/skills"
  link_path "$ROOT_DIR/ai/codex/config.toml" "$HOME/.codex/config.toml"
  link_path "$ROOT_DIR/ai/codex/agents" "$HOME/.codex/agents"
  link_path "$ROOT_DIR/ai/codex/skills" "$HOME/.codex/skills"

  log "Bootstrap complete. Restart OpenCode, Claude, or Codex after config changes."
}

main
```

- [ ] **Step 2: Make script executable**

Run:

```bash
chmod +x bootstrap.sh
```

Expected: command exits with status `0`.

- [ ] **Step 3: Validate shell syntax**

Run:

```bash
bash -n bootstrap.sh
```

Expected: command exits with status `0`.

- [ ] **Step 4: Run dry-run**

Run:

```bash
./bootstrap.sh --dry-run
```

Expected: prints validation and symlink actions without changing `$HOME`.

## Task 5: Add README

**Files:**
- Create: `README.md`

- [ ] **Step 1: Write README**

Write `README.md`:

```markdown
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
```

- [ ] **Step 2: Review README for quick path**

Run:

```bash
grep -q "./bootstrap.sh --dry-run" README.md && grep -q "Do not commit tokens" README.md
```

Expected: command exits with status `0`.

## Task 6: Final verification

**Files:**
- Verify all created files.

- [ ] **Step 1: Validate shell script**

Run:

```bash
bash -n bootstrap.sh
```

Expected: command exits with status `0`.

- [ ] **Step 2: Validate JSON files**

Run:

```bash
python3 -m json.tool ai/opencode/opencode.json >/dev/null && python3 -m json.tool ai/claude/settings.json >/dev/null && python3 -m json.tool ai/mcp/registry.json >/dev/null && python3 -m json.tool ai/mcp/opencode.json >/dev/null && python3 -m json.tool ai/mcp/claude.json >/dev/null && python3 -m json.tool ai/mcp/codex.json >/dev/null
```

Expected: command exits with status `0`.

- [ ] **Step 3: Run dry-run bootstrap**

Run:

```bash
./bootstrap.sh --dry-run
```

Expected: prints platform, repository path, JSON validation messages, symlink actions, and completion message.

- [ ] **Step 4: Check for obvious secrets**

Run:

```bash
grep -RniE '(ghp_|sk-[A-Za-z0-9]|bearer [A-Za-z0-9._-]{20,})' ai README.md bootstrap.sh
```

Expected: no matches.

- [ ] **Step 5: Inspect git status if repository has been initialized**

Run:

```bash
git status --short
```

Expected: if this is a Git repository, shows only intended new files. If Git is not initialized yet, initialize it before committing.

## Self-review

- Spec coverage: The plan creates the AI-only structure, bootstrap, symlink behavior, MCP registry/config files, secret policy docs, and verification steps described in the spec.
- Placeholder scan: No implementation step relies on TBD/TODO/fill-in-later language.
- Consistency: File paths match the design spec and are reused consistently across tasks.
