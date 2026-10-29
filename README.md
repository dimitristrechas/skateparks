# skateparks.gr

### How to set up the development environment

1. `git clone https://github.com/dimitristrechas/skateparks.git`
2. `cd skateparks`
3. Get the key files from a team member (`config/credentials/development.key`, `config/credentials/production.key`, `config/credentials/test.key`)
4. Copy .env.example to .env and .env.test and fill variables, for RAILS_MASTER_KEY use `config/credentials/development.key` and `config/credentials/test.key` respectively
5. `bundle install`
6. `npm install -g corepack && corepack enable && pnpm install`
7. `lefthook install` (sets up pre-commit hooks)
8. `sh scripts.sh`, select option **(1) Start / rebuild development server** and choose rebuild to build containers from scratch (or `sh scripts.sh dev rebuild --force`). For day-to-day restarts after the first build, use `sh scripts.sh dev up`.
9. Open browser on `localhost:3002`
10. Optionally run migrations with `sh scripts.sh dev migrate` (menu option **(18)**) if needed on first run
11. Optionally seed the database with option **(19) Seed the database** in `sh scripts.sh` (or `sh scripts.sh dev seed`)
12. Optionally set MCP token environment variables in shell profile (~/.zshrc or ~/.bashrc):
    - `export GITHUB_MCP_TOKEN=<your-token>`
    - `export LINEAR_MCP_TOKEN=<your-token>`
    - `export CONTEXT7_API_KEY=<your-token>`
    - `export CLOUDFLARE_API_TOKEN=<your-token>` (Cloudflare dashboard → Profile → API Tokens; needs Account Resources: Read plus Zone DNS, R2, Email Routing scopes you use)
    - `export DOKPLOY_URL=<dokploy-base-url>` (base URL only, no `/api`)
    - `export DOKPLOY_API_KEY=<your-token>` (Dokploy Settings → API/CLI)

    All AI tools (Cursor, Claude Code, OpenCode, Codex) read these env vars. Config files that must stay in sync: `opencode.json`, `.mcp.json`, `.cursor/mcp.json`, and `.codex/config.toml`. See [.agent-docs/ai-tooling.md](.agent-docs/ai-tooling.md).

### How to run tests

**Interactive menu:**

1. `sh scripts.sh`
2. Select option **(6) Start / rebuild test server** and choose rebuild for a fresh build (or `sh scripts.sh test-server rebuild --force`)
3. Select option **(7) Run all tests (with coverage)** or use `sh scripts.sh test --fast` for a quicker run

**CLI equivalents:**

```bash
sh scripts.sh test-server up              # start test container
sh scripts.sh test-server rebuild --force # fresh build
sh scripts.sh test                        # full suite with coverage
sh scripts.sh test --fast                 # without coverage
sh scripts.sh test test/models/foo_test.rb:42  # single file or line
sh scripts.sh test-server schema-load     # reload test DB schema
```

**Note**: This project uses Minitest (Rails default). See [docs/minitest-implementation.md](docs/minitest-implementation.md) for detailed testing guide.

### Development toolkit (`scripts.sh`)

`sh scripts.sh` is the preferred entry point for development, testing, linting, and CI checks.

**Interactive menu** — 23 options covering dev server, test server, tests, lint, security, CI, and database/cache:

```bash
sh scripts.sh
```

**Non-interactive subcommands:**

```bash
sh scripts.sh test [--fast] [path]         # Run tests (coverage, fast, or single file/line)
sh scripts.sh lint [--fix] [--full]        # Linters (fast by default; --full adds Zeitwerk)
sh scripts.sh security                     # Brakeman, bundle-audit, pnpm audit (parallel)
sh scripts.sh ci                           # Full CI parity checks (parallel)
sh scripts.sh dev <command>                # Development server commands
sh scripts.sh test-server <command>        # Test server commands
```

Dev commands: `up`, `rebuild`, `down`, `logs`, `console`, `bash`, `migrate`, `seed`, `reset`, `cache-clear`

Test-server commands: `up`, `rebuild`, `down`, `logs`, `console`, `bash`, `schema-load`

Destructive non-interactive commands require `--force`: `dev rebuild`, `dev reset`, and `test-server rebuild`.

### How to roll back production

Production deploys from `main` via GHCR + Dokploy. To revert a bad deploy, use the manual `Rollback production` workflow (`.github/workflows/rollback.yml`). It re-tags an existing `sha-<short>` image as `:latest`, reverses migrations added after the target, re-triggers Dokploy, and polls `https://skateparks.gr/healthcheck`.

1. Find the target: `git log --oneline -15`, or Dokploy → application `web` → Deployments, or GHCR package tags. GHCR keeps ~10 recent images, so you can only go back that far.
2. GitHub → Actions → `Rollback production` → `Run workflow` (leave branch on `main`).
3. `Target commit SHA`: leave empty for the previous successful Dokploy deployment, or paste a short/full SHA.
4. `Skip migration reversal`: leave unchecked unless the bad deploy had no migrations or you already reversed them manually.
5. `Run workflow` and watch the run: resolve target → verify image → reverse migrations (`ops-rollback-migrations` schedule) → re-tag `:latest` → Dokploy redeploy → healthcheck (up to ~10 min).
6. Verify: run is green, `https://skateparks.gr/healthcheck` is 200, Dokploy shows `Rollback to <sha> via rollback.yml`.

Requires repo secrets `DOKPLOY_API_KEY` and `DOKPLOY_WEBHOOK_KEY`. The workflow moves the `:latest` tag only — `main` history is unchanged, so follow up with `git revert` + push if the bad commit must be permanently undone. Note: `git revert` of a migration commit does not run `db:migrate:down` automatically — the file is deleted but the schema change stays. Reverse migrations first (via this workflow), or write a new migration that undoes the change.

### How to restore production database from R2 backup

Production Postgres (`postgres:17`, db `skateparks`) is backed up by Dokploy daily at midnight UTC to Cloudflare R2 (destination `R2-skateparks`, bucket `skateparks`, prefix `postgres/`). These are full daily dumps, not point-in-time recovery — you can restore to a daily boundary only.

1. Dokploy → Postgres service `postgres` → Backups: confirm the target date exists and shows `done` (e.g. the dump from before the bad deploy).
2. Stop or scale down app traffic if possible — everything written after the backup timestamp will be lost on restore.
3. Restore the selected backup from the Dokploy dashboard (or download the `postgres/...` file from the R2 `skateparks` bucket and `pg_restore` manually).
4. Restart/redeploy the app if needed and verify `https://skateparks.gr/healthcheck` returns 200 plus spot-check data.
5. If the bad deploy also included migrations, align code + schema: either run the `Rollback production` workflow above or `db:migrate:down VERSION=...` (newest first) before restoring, so the restored schema matches the running image.

**Further reading:**

- [.agent-docs/commands.md](.agent-docs/commands.md) — full command reference and direct Docker fallbacks
- [.agent-docs/operations.md](.agent-docs/operations.md) — ports, troubleshooting, CI overview
