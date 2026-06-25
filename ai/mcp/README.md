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

## Discovered MCPs

| MCP | Tools | Secret requirement |
| --- | --- | --- |
| `context7` | OpenCode, Claude, Codex | None discovered |
| `engram` | OpenCode, Claude, Codex | None discovered |
| `figma` | Codex | None discovered |
| `stitch` | Codex | `GOOGLE_STITCH_API_KEY` |
| `node_repl` | Codex | None discovered, machine-specific Codex app paths |

The original Stitch config contained a real API key. The repo version uses `{env:GOOGLE_STITCH_API_KEY}` instead.
