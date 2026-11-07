# Issue Tracker

Where issues for this repo live, and how engineering skills should read from and write to it.

## Tracker

**Linear**, reached through the `linear` MCP server.

- **Server & auth:** the `linear` MCP server with `LINEAR_MCP_TOKEN`. Setup, env-var scoping, and the `Bearer`-vs-bare-key difference: see `.agent-docs/ai-tooling.md` and `.agent-docs/operations.md#mcp-tokens`.
- **Team:** `SK8` — "Skateparks", id `d1544477-93d7-48c9-b337-ac4a077818da`. The workspace also contains `PERS` ("Personal-site"); this repo is **always** `SK8`.
- **Issue identifiers:** `SK8-<n>` — always use the full identifier (e.g. `SK8-98`). Never refer to a bare `#42`.
- **Commit scope:** use the issue identifier in the conventional-commit scope, e.g. `feat(SK8-98): …` (see `.agent-docs/conventions.md`).

## How to interact with it

Use the `linear` MCP server for every tracker operation. Do not call the Linear REST API directly and do not scrape the web UI.

- **Read:** `list_issues`, `get_issue`, `list_issue_labels`, `list_projects`, `list_teams`, `list_comments`
- **Write:** `create_issue`, `update_issue`, `create_comment`, `create_issue_label`
- Discover the exact tool names and arguments from the MCP server at call time if they differ from the list above.

Resolve the target **project** with `list_projects`. The workspace has two teams (`SK8`, `PERS`); this repo's work belongs to `SK8`. If a Linear call needs a project and the destination is not obvious from the request, ask the user rather than guessing.

## PRs as a request surface

**Off.** Triage discovery only covers Linear issues. GitHub pull requests are not part of the triage queue. An explicitly named PR can still be looked at when the user asks, but skills should not scan `dimitristrechas/skateparks` PRs for triage work.

## If the tracker is unreachable

If the `linear` MCP server is not available or `LINEAR_MCP_TOKEN` is unset:

1. Report it plainly — name the env var and how to set it (see `.agent-docs/operations.md`).
2. Do not substitute GitHub Issues, local markdown files, or invent identifiers.
3. Continue with any codebase-only work that doesn't need tracker access.

## Conventions for tracker writes

- Every comment posted during triage starts with the triage skill's AI disclaimer.
- One category label (`bug` / `enhancement`) and one state label per triaged issue.
- Prefer Linear's native priority/estimate fields over encoding them in labels.
