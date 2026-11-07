# Operations & Troubleshooting

## Production credentials

Edit production secrets (requires `config/credentials/production.key` to exist):

```bash
VISUAL="code --wait" bin/rails credentials:edit --environment production
```

## Database version

Canonical dev/test database is **PostgreSQL 18** (`postgres:18-alpine` in `docker-compose.yml`).

Inspect the running instance:

```bash
docker compose exec skateparks-db psql -U root -c "SELECT version();"
```

## Node version

Node **26.13.0** is pinned in `.nvmrc` and `.node-version`. `package.json` declares `engines.node >= 26` and `pnpm-workspace.yaml` sets `engineStrict: true`, so `pnpm install` fails with a clear error under older Node. Interactive shells switch automatically through the nvm `.nvmrc` hook; `scripts.sh` also prepends the matching nvm `bin` directory, so lint/format commands use the pinned version even in non-interactive shells (IDEs, agents).

## Docker architecture

One compose stack (`docker-compose.yml`, project `skateparks`):

| Service            | Container          | Purpose                                                           | Host port |
| ------------------ | ------------------ | ----------------------------------------------------------------- | --------- |
| `skateparks-db`    | `skateparks-db`    | PostgreSQL — hosts `skateparks_development` and `skateparks_test` | 5434      |
| `skateparks-redis` | `skateparks-redis` | Redis — logical DB `/1` (dev) and `/2` (test)                     | 6379      |
| `skateparks-web`   | `skateparks-web`   | Development server (`foreman`: web + Tailwind watch + Sidekiq)    | 3002      |

Tests do **not** use a long-running web service. `sh scripts.sh test` starts a disposable container from the same `skateparks-dev` image with `RAILS_ENV=test` and the values from `.env.test`, then removes it. This keeps test runs isolated without a second always-on stack.

Codebase is volume-mounted — code changes apply immediately without rebuilds.

## Dockerfiles

| File                     | Purpose                                                                        |
| ------------------------ | ------------------------------------------------------------------------------ |
| `Dockerfile`             | Production — multi-stage, non-root user, `foreman start`                       |
| `Dockerfile.development` | Development and tests — `ENTRYPOINT docker-entrypoint`, `foreman Procfile.dev` |

## Migrating from the two-stack setup

The old `docker-compose.development.yml` / `docker-compose.test.yml` stacks are gone. Existing containers are not reused because they are renamed, so remove them once before the first `dev up` (host ports 5434/6379/3002 would otherwise conflict):

```bash
docker rm -f rails-app postgres-17 skateparks-redis rails-app-test postgres-17-test skateparks-redis-test
docker volume rm skateparks-test_postgres_data_test skateparks-test_app-storage 2>/dev/null
```

Update `.env.test` to point at the shared services: `PGPORT=5432`, `POSTGRES_HOST=skateparks-db`, `POSTGRES_DB=skateparks_test`, `REDIS_URL=redis://skateparks-redis:6379/2`.

The development volumes (`skateparks_postgres_data`, `skateparks_app-storage`, `skateparks_redis_data`) are reused, so development data survives. The test database is recreated on the shared Postgres by `sh scripts.sh test-server up` (or automatically by `sh scripts.sh test`).

When adding gems requiring native extensions, rebuild the image:

```bash
sh scripts.sh dev rebuild --force
# or
docker compose build skateparks-web
```

## Fresh environment setup

```bash
git clone https://github.com/dimitristrechas/skateparks.git
cd skateparks
# Get key files from team: config/credentials/development.key, test.key, production.key
cp .env.example .env && cp .env.example .env.test
# Fill in .env and .env.test (RAILS_MASTER_KEY = contents of dev.key / test.key)
bundle install && npm install -g corepack && corepack enable && pnpm install
lefthook install
sh scripts.sh dev up
sh scripts.sh test-server up   # create/prepare the test database (optional; test runs do this too)
```

## Environment files

- `.env` — development environment variables
- `.env.test` — test environment variables
- `config/credentials/development.key` — dev master key (gitignored)
- `config/credentials/test.key` — test master key (gitignored)
- `config/credentials/production.key` — production master key (gitignored)

Never commit `.env`, `.env.test`, or `*.key` files.

## MCP tokens

Export from a file sourced by **every** shell, not just interactive ones. On zsh that means `~/.zshenv` (or a helper it sources); `~/.zshrc` is skipped by `zsh -c`, by non-interactive scripts, and by MCP servers spawned without a login shell — which is how the Linear MCP silently disappears from an agent's tool list.

```bash
export GITHUB_MCP_TOKEN=<your-token>
export LINEAR_MCP_TOKEN=<your-token>
export CONTEXT7_API_KEY=<your-token>
export DOKPLOY_URL=<dokploy-base-url> # base URL only, no /api
export DOKPLOY_API_KEY=<your-token> # Dokploy Settings → API/CLI
```

Verify before blaming the config — an unset variable and a wrong URL fail the same way:

```bash
zsh -c 'test -n "$LINEAR_MCP_TOKEN" && echo ok || echo unset'
```

Auth shapes differ per server: Linear's MCP endpoint (`https://mcp.linear.app/mcp`) wants `Authorization: Bearer <linear-api-key>` and returns 401 without the prefix; the Linear GraphQL API at `api.linear.app` wants the bare key and rejects the `Bearer` prefix.

Apps launched from the Dock/Spotlight inherit neither `~/.zshenv` nor `~/.zshrc`, so they need `launchctl setenv LINEAR_MCP_TOKEN "$(zsh -ic 'print -r -- $LINEAR_MCP_TOKEN')"` (or launch the app from a terminal). Restart the agent session after changing the environment so MCP servers are respawned with it.

## CI/CD pipeline

Seven jobs in `.github/workflows/ci-cd.yml`:

1. **workflow-lint** — `actionlint` plus `hadolint` for `Dockerfile` and `Dockerfile.development`
2. **test** — `bundle install` → conditional `pnpm install` → `db:create + schema:load` → conditional `assets:precompile` → `bin/rails test` across the test directories
3. **rubocop-brakeman** — `rails zeitwerk:check` + `rubocop --force-exclusion` + `brakeman -q --no-pager` + `bundle-audit check --update`
4. **herb-prettier** — `prettier:check` + `herb:lint` + `herb:format:check` + `pnpm audit --audit-level moderate`
5. **docker-validate** — PR-only `linux/arm64` application image build validation
6. **docker-publish** — push-to-`main` GHCR image build and publish
7. **deploy** — push-to-`main` Dokploy webhook trigger

The verification jobs (`workflow-lint`, `test`, `rubocop-brakeman`, `herb-prettier`) must pass before image validation or publish runs.

## Rollback (manual)

`.github/workflows/rollback.yml` (manual `workflow_dispatch` only) rolls production back to a target commit: it re-tags the existing `sha-<short>` image as `:latest`, reverses migrations applied after the target via the `ops-rollback-migrations` Dokploy schedule (auto-created on first use), re-triggers the Dokploy webhook, and polls `/healthcheck`. Empty `sha` input defaults to the previous successful Dokploy deployment. Requires the `DOKPLOY_API_KEY` repository secret (Settings → Secrets and variables → Actions); the schedule executes `db:migrate:down` inside the running production container. GHCR keeps ~10 recent publishes (`cleanup-ghcr.yml`), which bounds how far back a rollback can reach.

## Renovate (dependency updates)

Self-hosted Renovate runs via `.github/workflows/renovate.yml` on a daily cron (`0 0 * * *`, 00:00 UTC), plus manual `workflow_dispatch`. GitHub Actions may delay scheduled runs by several hours; Renovate has no separate PR schedule, so every successful workflow run can open PRs. Configuration: `.github/renovate-config.json5` (runner settings) and `renovate.json` (package rules).

PR strategy: one grouped PR for all non-major updates, plus separate grouped PRs for major updates by ecosystem (Ruby, npm, GitHub Actions, Docker). `prHourlyLimit` is disabled so a scheduled run can open every group in one pass. Use the Dependency Dashboard issue to force rate-limited or pending branches if needed.

**One-time GitHub setup** (repository Settings):

1. Create a classic PAT at https://github.com/settings/tokens with scopes `repo` and `workflow` (workflow scope is required to update `.github/workflows/*`).
2. Add repository secret `RENOVATE_TOKEN` with the PAT value (Settings → Secrets and variables → Actions).
3. Enable **Allow GitHub Actions to create and approve pull requests** (Settings → Actions → General → Workflow permissions).

After merge, trigger the Renovate workflow manually once to verify before the next scheduled run.

## Pre-commit hooks (Lefthook)

Hooks defined in `lefthook.yml`:

**pre-commit** (auto-fix, priority 1):

- `prettier --write` on changed JS/CSS/JSON
- `herb --format` + `herb --lint --fix` on changed ERB
- `rubocop -A` on changed Ruby

**pre-commit** (check, priority 2 — runs after fixes):

- Validates linting passes after auto-fixes

**pre-push**:

- `brakeman -q --no-pager` security scan
- `bundle exec bundle-audit check --update` gem vulnerability scan

If a pre-commit hook fails, the commit is blocked. Run `sh scripts.sh lint --fix` or see [commands.md](commands.md).

## Troubleshooting

**Container won't start**: Check `docker compose logs skateparks-web` for errors.

**Database connection refused**: Ensure `skateparks-db` is running and healthy (`docker compose ps`). Test runs start it automatically.

**Tests fail with DB errors**: Reload schema:

```bash
sh scripts.sh test-server schema-load
```

**Gem changes not taking effect**: Volume mount means Gemfile changes apply, but native extensions need rebuild.

**Permission errors on volume**: Check `CODEBASE_VOLUME` env var is set in `.env`.

**Never run `bin/rails test` locally** — tests require the Docker DB/Redis.

**Never `docker compose down -v` in production** — destroys named volumes.

## WSL `scripts.sh` encoding

CRLF line endings can break `scripts.sh` on WSL. Fix:

```bash
sudo apt-get install dos2unix
dos2unix scripts.sh
```
