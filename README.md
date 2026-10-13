# AI Dotfiles

Source of truth for OpenCode, Claude, Codex, skills, agents and MCP configuration. Shell/editor configuration and full machine bootstrap remain out of scope.

## Install

```sh
./bootstrap.sh --dry-run
./bootstrap.sh
```

Restart the affected tool after configuration changes. Bootstrap links files from this checkout into your home directory; keep the checkout in place. Existing real files/directories move to `.backups/<timestamp>/`. Correct links remain untouched; an incorrect link requires `--force`.

macOS receives the full configuration. Linux/WSL2 receives portable skills, agents, prompts and instructions; the script lists skipped macOS-specific configuration. Do not manually link the skipped files: they contain machine-specific paths or settings.

## Maintain

- `ai/shared`: shared skills, agents and prompts.
- `ai/opencode`, `ai/claude`, `ai/codex`: runtime-specific files; their skill/delegation contracts deliberately differ.
- [MCP configuration](ai/mcp/README.md): neutral registry plus per-tool schema mirrors, maintained separately.
- [Portable model profiles](ai/model-profiles/README.md): apply model routing after Gentle AI installation and OpenAI authentication; includes dry-run and rollback.

Run `python3 -m unittest discover -s tests` for model-profile checks. Inspect bootstrap with `bash -n bootstrap.sh` and `./bootstrap.sh --dry-run`; dry-run does not install links. JSON checks require python3. Bootstrap does not validate TOML.

## Secrets and local state

Never commit tokens, keys, bearer values or authentication. Keep values in a secret manager or local environment; tracked configuration contains placeholders/environment references only. Set `GOOGLE_STITCH_API_KEY` outside this repository for Stitch.

Runtime state, caches, histories, sessions, SQLite databases, backups and machine-specific credentials stay untracked. Model-profile application copies no authentication, secrets or runtime state.
