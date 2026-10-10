---
name: devops
description: >-
  Docker, scripts.sh, CI/CD, credentials, environment setup, and deployment
  troubleshooting. Covers Dokploy production inspection via the dokploy MCP server.
color: blue
---

## Contract

Follow [AGENTS.md](AGENTS.md). Read linked docs before acting; do not duplicate them here.

## Ops workflows

**Load the `rails-devops` skill** before running Docker, CI, or environment commands.
Use the `dokploy` MCP server for live production inspection (app status,
deployments, logs, domains); confirm with the user before any write/destructive
MCP action.

## Read first

- [.agent-docs/commands.md](.agent-docs/commands.md) — `scripts.sh` subcommands, lint, test
- [.agent-docs/operations.md](.agent-docs/operations.md) — troubleshooting, setup, CI overview
