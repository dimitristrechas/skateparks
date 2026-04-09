# AI tooling across Cursor, Claude Code, and OpenCode

## Canonical guidance

- **`AGENTS.md`** — canonical project instructions and product-quality expectations.
- **`.cursor/rules/*.mdc`** — Cursor-specific application of the same rules (e.g. always-on reminders).

Claude Code subagents (`.claude/agents/*.md`), skills (`.claude/skills/*/SKILL.md`), and OpenCode’s `opencode.json` should **mirror** `AGENTS.md`, not introduce conflicting policies.

## OpenCode

- Agent definitions live in `opencode.json` and load prompts from `{file:./.claude/agents/<name>.md}`.
- Edit behavior in `AGENTS.md` first, then align agent markdown if a role needs extra detail.

## MCP configuration alignment

Three files define MCP servers for different clients. **Keep the same servers, URLs, and env var names** across all three.

| File               | Notes                                                                                      |
| ------------------ | ------------------------------------------------------------------------------------------ |
| `opencode.json`    | Uses `{env:VAR}` for environment substitution in OpenCode.                                 |
| `.mcp.json`        | Uses `${VAR}` (shell-style) for Codex-style clients.                                       |
| `.cursor/mcp.json` | Uses `${env:VAR}` for GitHub token env; `{env:VAR}` for Linear header (Cursor convention). |

**Required env vars (examples):** `LINEAR_MCP_TOKEN`, `GITHUB_MCP_TOKEN` — names must stay consistent; only the **placeholder syntax** differs per file format.

Do not add GitHub Copilot-specific MCP endpoints or agent files to this repository.
