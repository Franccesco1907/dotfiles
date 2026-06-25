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

skip_platform_path() {
  local platform="$1"
  local path="$2"
  local reason="$3"

  log "Skip on $platform: $path ($reason)"
}

run() {
  if [ "$DRY_RUN" -eq 1 ]; then
    log "DRY-RUN: $*"
  else
    "$@"
  fi
}

detect_platform() {
  if [ -n "${DOTFILES_PLATFORM:-}" ]; then
    echo "$DOTFILES_PLATFORM"
    return
  fi

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
  if [ "$DRY_RUN" -eq 1 ]; then
    log "Would back up: $target -> $destination"
  else
    log "Backed up: $target -> $destination"
  fi
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
  if [ "$DRY_RUN" -eq 1 ]; then
    log "Would link: $target -> $source"
  else
    log "Linked: $target -> $source"
  fi
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

  if grep -Eiq '(ghp_|sk-[A-Za-z0-9]|bearer[[:space:]]+[A-Za-z0-9._-]{20,})' "$file"; then
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
  link_path "$ROOT_DIR/ai/opencode/AGENTS.md" "$HOME/.config/opencode/AGENTS.md"
  link_path "$ROOT_DIR/ai/opencode/agents" "$HOME/.config/opencode/agents"
  link_path "$ROOT_DIR/ai/opencode/skills" "$HOME/.config/opencode/skills"
  link_path "$ROOT_DIR/ai/opencode/prompts" "$HOME/.config/opencode/prompts"
  link_path "$ROOT_DIR/ai/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
  link_path "$ROOT_DIR/ai/claude/agents" "$HOME/.claude/agents"
  link_path "$ROOT_DIR/ai/claude/skills" "$HOME/.claude/skills"
  link_path "$ROOT_DIR/ai/claude/commands" "$HOME/.claude/commands"
  link_path "$ROOT_DIR/ai/claude/themes" "$HOME/.claude/themes"
  link_path "$ROOT_DIR/ai/codex/agents.md" "$HOME/.codex/agents.md"
  link_path "$ROOT_DIR/ai/codex/engram-instructions.md" "$HOME/.codex/engram-instructions.md"
  link_path "$ROOT_DIR/ai/codex/engram-compact-prompt.md" "$HOME/.codex/engram-compact-prompt.md"
  link_path "$ROOT_DIR/ai/codex/agents" "$HOME/.codex/agents"
  link_path "$ROOT_DIR/ai/codex/skills" "$HOME/.codex/skills"

  if [ "$platform" = "macos" ]; then
    link_path "$ROOT_DIR/ai/opencode/opencode.json" "$HOME/.config/opencode/opencode.json"
    link_path "$ROOT_DIR/ai/opencode/opencode-notifier.json" "$HOME/.config/opencode/opencode-notifier.json"
    link_path "$ROOT_DIR/ai/opencode/tui.json" "$HOME/.config/opencode/tui.json"
    link_path "$ROOT_DIR/ai/opencode/commands" "$HOME/.config/opencode/commands"
    link_path "$ROOT_DIR/ai/opencode/plugins" "$HOME/.config/opencode/plugins"
    link_path "$ROOT_DIR/ai/opencode/tui-plugins" "$HOME/.config/opencode/tui-plugins"
    link_path "$ROOT_DIR/ai/claude/settings.json" "$HOME/.claude/settings.json"
    link_path "$ROOT_DIR/ai/claude/statusline.sh" "$HOME/.claude/statusline.sh"
    link_path "$ROOT_DIR/ai/claude/tweakcc-theme.json" "$HOME/.claude/tweakcc-theme.json"
    link_path "$ROOT_DIR/ai/claude/mcp" "$HOME/.claude/mcp"
    link_path "$ROOT_DIR/ai/codex/config.toml" "$HOME/.codex/config.toml"
    link_path "$ROOT_DIR/ai/codex/hooks.json" "$HOME/.codex/hooks.json"
    link_path "$ROOT_DIR/ai/codex/sdd-strong.config.toml" "$HOME/.codex/sdd-strong.config.toml"
    link_path "$ROOT_DIR/ai/codex/sdd-mid.config.toml" "$HOME/.codex/sdd-mid.config.toml"
    link_path "$ROOT_DIR/ai/codex/sdd-cheap.config.toml" "$HOME/.codex/sdd-cheap.config.toml"
    link_path "$ROOT_DIR/ai/codex/rules" "$HOME/.codex/rules"
  else
    skip_platform_path "$platform" "~/.config/opencode/opencode.json" "contains macOS absolute paths and file:// plugin references"
    skip_platform_path "$platform" "~/.config/opencode/opencode-notifier.json" "not verified portable outside macOS"
    skip_platform_path "$platform" "~/.config/opencode/tui.json" "contains macOS absolute plugin path"
    skip_platform_path "$platform" "~/.config/opencode/commands" "contains macOS absolute symlink targets"
    skip_platform_path "$platform" "~/.config/opencode/plugins" "paired with skipped macOS opencode.json plugin config"
    skip_platform_path "$platform" "~/.config/opencode/tui-plugins" "paired with skipped macOS tui.json"
    skip_platform_path "$platform" "~/.claude/settings.json" "contains macOS-specific statusline and plugin settings"
    skip_platform_path "$platform" "~/.claude/statusline.sh" "not verified portable outside macOS"
    skip_platform_path "$platform" "~/.claude/tweakcc-theme.json" "not required for portable setup"
    skip_platform_path "$platform" "~/.claude/mcp" "contains /opt/homebrew command paths"
    skip_platform_path "$platform" "~/.codex/config.toml" "contains /Users, /Applications, and /opt/homebrew paths"
    skip_platform_path "$platform" "~/.codex/hooks.json" "paired with skipped macOS Codex config"
    skip_platform_path "$platform" "~/.codex/sdd-*.config.toml" "profile configs are macOS-derived"
    skip_platform_path "$platform" "~/.codex/rules" "contains macOS absolute script allowlist paths"
  fi

  log "Bootstrap complete. Restart OpenCode, Claude, or Codex after config changes."
}

main
