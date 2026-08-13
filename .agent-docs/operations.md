# Operations & Troubleshooting

## Production credentials

Edit production secrets (requires `config/credentials/production.key` to exist):

```bash
VISUAL="code --wait" bin/rails credentials:edit --environment production
```

## Database version

Canonical dev/test database is **PostgreSQL 17** (see `postgres:17-alpine` in `docker-compose.development.yml` and `docker-compose.test.yml`).

Inspect the running development instance:

```bash
docker compose -f docker-compose.development.yml exec db psql -U postgres -c "SELECT version();"
```

## Docker architecture

| Environment | Compose file                     | Web service           | DB port | Redis port | App port |
| ----------- | -------------------------------- | --------------------- | ------- | ---------- | -------- |
| Development | `docker-compose.development.yml` | `skateparks-web`      | 5434    | 6379       | 3002     |
| Test        | `docker-compose.test.yml`        | `skateparks-web-test` | 5433    | 6380       | 3003     |

Codebase is volume-mounted in both environments — code changes apply immediately without rebuilds.

## Dockerfiles

| File                     | Purpose                                                      |
| ------------------------ | ------------------------------------------------------------ |
| `Dockerfile`             | Production — multi-stage, non-root user, `foreman start`     |
| `Dockerfile.development` | Dev — `ENTRYPOINT docker-entrypoint`, `foreman Procfile.dev` |
| `Dockerfile.test`        | Test — `RAILS_ENV=test`, no dev Procfile                     |

When adding gems requiring native extensions, rebuild the image:

```bash
sh scripts.sh dev rebuild --force
# or
docker compose -f docker-compose.development.yml build
```

## Fresh environment setup

```bash
git clone https://github.com/dimitristrechas/skateparks.git
cd skateparks
# Get key files from team: config/credentials/development.key, test.key, production.key
cp .env.example .env && cp .env.example .env.test
# Fill in .env and .env.test (RAILS_MASTER_KEY = contents of dev.key / test.key)
bundle install && corepack enable && pnpm install
lefthook install
sh scripts.sh dev up
```

## Environment files

- `.env` — development environment variables
- `.env.test` — test environment variables
- `config/credentials/development.key` — dev master key (gitignored)
- `config/credentials/test.key` — test master key (gitignored)
- `config/credentials/production.key` — production master key (gitignored)

Never commit `.env`, `.env.test`, `*.key` files, or `.secrets/` contents.

## MCP tokens

Store in `.secrets/` (gitignored):

```bash
mkdir .secrets
echo "your-token" > .secrets/github-mcp-token
echo "your-token" > .secrets/linear-token
```

Then in shell profile: `export GITHUB_MCP_TOKEN=$(cat ~/path/to/.secrets/github-mcp-token)`

## CI/CD pipeline

Seven jobs in `.github/workflows/ci-cd.yml`:

1. **workflow-lint** — `actionlint` plus `hadolint` for `Dockerfile`, `Dockerfile.development`, and `Dockerfile.test`
2. **test** — `bundle install` → conditional `pnpm install` → `db:create + schema:load` → conditional `assets:precompile` → `bin/rails test` across the test directories
3. **rubocop-brakeman** — `rails zeitwerk:check` + `rubocop --force-exclusion` + `brakeman -q --no-pager` + `bundle-audit check --update`
4. **herb-prettier** — `prettier:check` + `herb:lint` + `herb:format:check` + `pnpm audit --audit-level moderate`
5. **docker-validate** — PR-only `linux/arm64` application image build validation
6. **docker-publish** — push-to-`main` GHCR image build and publish
7. **deploy** — push-to-`main` Dokploy webhook trigger

The verification jobs (`workflow-lint`, `test`, `rubocop-brakeman`, `herb-prettier`) must pass before image validation or publish runs.

## Renovate (dependency updates)

Weekly self-hosted Renovate runs via `.github/workflows/renovate.yml` (Sunday 00:00 UTC, plus manual `workflow_dispatch`). Configuration: `.github/renovate-config.json5` (runner settings) and `renovate.json` (package rules).

**One-time GitHub setup** (repository Settings):

1. Create a classic PAT at https://github.com/settings/tokens with scopes `repo` and `workflow` (workflow scope is required to update `.github/workflows/*`).
2. Add repository secret `RENOVATE_TOKEN` with the PAT value (Settings → Secrets and variables → Actions).
3. Enable **Allow GitHub Actions to create and approve pull requests** (Settings → Actions → General → Workflow permissions).

After merge, trigger the Renovate workflow manually once to verify before the weekly cron runs.

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

**Database connection refused**: Ensure `skateparks-db` (dev) or `skateparks-db-test` (test) is running and healthy.

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
