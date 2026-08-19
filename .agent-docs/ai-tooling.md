# AI tooling across Cursor, Claude Code, and OpenCode

## Canonical guidance

- **`AGENTS.md`** — canonical project instructions and product-quality expectations.
- **`.cursor/rules/*.mdc`** — Cursor-specific application of the same rules (e.g. always-on reminders).
- **`CLAUDE.md`** — Claude Code entry point; defers to `AGENTS.md`.

Claude Code subagents (`.claude/agents/*.md`), skills (`.claude/skills/*/SKILL.md`), and OpenCode’s `opencode.json` should **mirror** `AGENTS.md`, not introduce conflicting policies.

## Per-tool file map

| Tool            | Rules                               | Subagents                                                                      | Skills                                                                         | MCP config                  | Other                                          |
| --------------- | ----------------------------------- | ------------------------------------------------------------------------------ | ------------------------------------------------------------------------------ | --------------------------- | ---------------------------------------------- |
| **Cursor**      | `AGENTS.md` + `.cursor/rules/*.mdc` | `.claude/agents/` (canonical); `.cursor/agents/` symlinks for Cursor discovery | `.claude/skills/` (canonical); `.cursor/skills/` symlinks for Cursor discovery | `.cursor/mcp.json`          | —                                              |
| **Claude Code** | `CLAUDE.md` → `AGENTS.md`           | `.claude/agents/` (auto-discovered)                                            | `.claude/skills/` (auto-discovered)                                            | `.mcp.json`                 | `.claude/settings.local.json` gitignored       |
| **OpenCode**    | `AGENTS.md` (via agent prompts)     | `opencode.json` → `{file:./.claude/agents/...}`                                | `.claude/skills/*/SKILL.md` (auto-discovered via native `skill` tool)          | `opencode.json` `mcp` block | `permission` block (git safety + skill access) |

**Canonical source for subagents and skills:** `.claude/agents/` and `.claude/skills/`. Cursor symlinks under `.cursor/agents/` and `.cursor/skills/` point at those paths so official Cursor discovery works without duplicating content.

## OpenCode

- Agent definitions live in `opencode.json` and load prompts from `{file:./.claude/agents/<name>.md}`.
- Skills are **not** registered in `opencode.json`. OpenCode auto-discovers `.claude/skills/<name>/SKILL.md` and loads them on demand via the native `skill` tool (`skill({ name: "rails-testing" })`). See [OpenCode skills docs](https://opencode.ai/docs/skills/).
- Edit behavior in `AGENTS.md` first, then align agent markdown or skills if a role needs extra detail.
- When editing an agent’s YAML `description`, also update the matching `opencode.json` `agent.<name>.description`.
- **`permission` block** (OpenCode-only): `git commit`, `git push`, `git reflog`, and `git reset` are set to `ask`; `skill.*` is set to `allow` so project skills appear in `<available_skills>`. Not mirrored in Cursor or Claude Code configs; `AGENTS.md` (“Do not commit unless explicitly instructed”) provides the policy overlap.

### Skill frontmatter (OpenCode)

Each `.claude/skills/<name>/SKILL.md` must have:

- `name` — required; must match the directory name (regex: `^[a-z0-9]+(-[a-z0-9]+)*$`)
- `description` — required; 1–1024 characters; used for routing in `<available_skills>`
- `SKILL.md` — filename must be all caps

Optional: `compatibility: opencode`, `license`, `metadata`.

Thin agents should instruct loading skills via the `skill` tool (e.g. `rails-implementer` → `rails-testing`; `devops` → `rails-devops`).

## MCP configuration alignment

Three files define MCP servers for different clients. **Keep the same servers, URLs, and env var names** across all three.

| File               | Client      | Notes                                                                                                                  |
| ------------------ | ----------- | ---------------------------------------------------------------------------------------------------------------------- |
| `opencode.json`    | OpenCode    | Uses `{env:VAR}` for environment substitution. All servers use `type: remote` with `oauth: false`. Bearer auth headers. |
| `.mcp.json`        | Claude Code | Uses `${VAR}` (shell-style) for env substitution. All servers use `type: http` (Streamable HTTP).                       |
| `.cursor/mcp.json` | Cursor      | Remote Streamable HTTP. Bearer auth headers use `${env:VAR}` (Cursor convention).                                      |

**Required env vars:** `LINEAR_MCP_TOKEN`, `GITHUB_MCP_TOKEN`, `CONTEXT7_API_KEY` — names must stay consistent; only the **placeholder syntax** differs per file format.

**Servers:** [GitHub MCP](https://github.com/github/github-mcp-server) remote at `https://api.githubcopilot.com/mcp/`; [Linear MCP](https://linear.app/docs/mcp) at `https://mcp.linear.app/mcp`; [Exa MCP](https://docs.exa.ai/reference/mcp) at `https://mcp.exa.ai/mcp`; [Context7 MCP](https://github.com/upstash/context7) at `https://mcp.context7.com/mcp`. The deprecated npm package `@modelcontextprotocol/server-github` is not used.

**Node / `npx`:** [`bin/mcp-npx`](../bin/mcp-npx) remains available for any future stdio MCP servers that need `npx` with a login-shell `PATH` (common with nvm/fnm).

**Optional local storage:** store raw tokens in `.secrets/` (gitignored) and export them to the env vars above in your shell profile. See [README.md](../README.md) setup step 11.

Do not add GitHub Copilot-specific MCP endpoints or agent files to this repository.

## Change checklist

When adding or changing an agent, skill, or MCP server:

1. Edit `AGENTS.md` if behavior or policy changes.
2. Add or update `.claude/agents/<name>.md` or `.claude/skills/<name>/SKILL.md`.
3. Register new subagents in `opencode.json` (`description`, `mode: subagent`, `{file:./.claude/agents/<name>.md}` prompt). Skills do not need `opencode.json` entries.
4. Update all three MCP files (`opencode.json`, `.mcp.json`, `.cursor/mcp.json`) when servers or env var names change.
5. Add matching symlinks under `.cursor/agents/` or `.cursor/skills/` when adding agents or skills.

## Verification checklist

Quick manual audit after changes:

- Agent filenames in `.claude/agents/` match keys in `opencode.json` `agent`.
- Skill directory names match `name` in each `SKILL.md` frontmatter.
- MCP server names and env var names are identical across `opencode.json`, `.mcp.json`, and `.cursor/mcp.json`.
- Agent and skill bodies do not contradict `AGENTS.md` (i18n, a11y, commit policy, etc.).
- `opencode.json` includes `permission.skill` if OpenCode should list project skills.
- README env var names match this document.
- `.cursor/agents/` and `.cursor/skills/` symlinks resolve to `.claude/` counterparts.
