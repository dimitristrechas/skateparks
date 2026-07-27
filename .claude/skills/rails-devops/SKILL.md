---
name: rails-devops
description: >-
  Docker, scripts.sh, CI/CD, credentials, and environment setup for this Rails app.
  Use for container issues, dev/test server workflows, and deployment troubleshooting.
compatibility: opencode
---

# Rails DevOps

Canonical project instructions live in **`AGENTS.md`**. Full command reference: **`.agent-docs/commands.md`**. Troubleshooting and setup: **`.agent-docs/operations.md`**.

## When to use me

Use when managing Docker containers, debugging build issues, running CI-parity checks, setting up a fresh environment, or troubleshooting deployment and credentials.

## What I do

- `scripts.sh` entry points for dev, test, lint, security, and CI
- Docker compose files, service names, and ports for this project
- Pointers to operations docs for troubleshooting and environment files

## scripts.sh (preferred)

```bash
sh scripts.sh                              # Interactive menu
sh scripts.sh dev up                       # Start development server
sh scripts.sh dev rebuild --force          # Rebuild development containers
sh scripts.sh test-server up               # Start test server
sh scripts.sh test-server schema-load      # Reload test DB schema
sh scripts.sh test                         # All tests with coverage
sh scripts.sh test --fast                  # All tests without coverage
sh scripts.sh lint                         # Fast linter checks
sh scripts.sh lint --fix                   # Auto-fix then re-check
sh scripts.sh security                     # Brakeman, bundle-audit, pnpm audit
sh scripts.sh ci                           # Full CI parity — run before push/PR
```

**Before push or opening a PR:** `sh scripts.sh test --fast` then `sh scripts.sh ci`. Lint-only checks miss `pnpm audit`, which fails the `herb-prettier` CI job when transitive JS advisories are present.

## Docker architecture

| Environment | Compose file                     | Web service           | DB port | Redis port | App port |
| ----------- | -------------------------------- | --------------------- | ------- | ---------- | -------- |
| Development | `docker-compose.development.yml` | `skateparks-web`      | 5434    | 6379       | 3002     |
| Test        | `docker-compose.test.yml`        | `skateparks-web-test` | 5433    | 6380       | 3003     |

Codebase is volume-mounted — code changes apply without rebuilds. Native-extension gems need image rebuild (`sh scripts.sh dev rebuild --force`).

## CI/CD (summary)

Seven jobs in `.github/workflows/ci-cd.yml`: `workflow-lint`, `test`, `rubocop-brakeman`, `herb-prettier`, `docker-validate`, `docker-publish`, `deploy`. Verification jobs must pass before image validation or publish. See `.agent-docs/operations.md` for details.

## What NOT to do

- Never run `bin/rails test` locally — tests require the Docker DB/Redis
- Never `docker compose down -v` in production (destroys named volumes)
- Never commit `.env`, `.env.test`, `*.key` files, or `.secrets/` contents
