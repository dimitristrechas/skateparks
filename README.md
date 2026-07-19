# skateparks.gr

### How to set up the development environment

1. `git clone https://github.com/dimitristrechas/skateparks.git`
2. `cd skateparks`
3. Get the key files from a team member (`config/credentials/development.key`, `config/credentials/production.key`, `config/credentials/test.key`)
4. Copy .env.example to .env and .env.test and fill variables, for RAILS_MASTER_KEY use `config/credentials/development.key` and `config/credentials/test.key` respectively
5. `bundle install`
6. `corepack enable && pnpm install`
7. `lefthook install` (sets up pre-commit hooks)
8. `sh scripts.sh`, select option **(1) Start / rebuild development server** and choose rebuild to build containers from scratch (or `sh scripts.sh dev rebuild --force`). For day-to-day restarts after the first build, use `sh scripts.sh dev up`.
9. Open browser on `localhost:3002`
10. Optionally run migrations with `sh scripts.sh dev migrate` (menu option **(18)**) if needed on first run
11. Optionally seed the database with option **(19) Seed the database** in `sh scripts.sh` (or `sh scripts.sh dev seed`)
12. Optionally set MCP token environment variables in shell profile (~/.zshrc or ~/.bashrc):
    - `export GITHUB_MCP_TOKEN=<your-token>`
    - `export LINEAR_MCP_TOKEN=<your-token>`

    All AI tools (Cursor, Claude Code, OpenCode) read these env vars. Config files that must stay in sync: `opencode.json`, `.mcp.json`, and `.cursor/mcp.json`. See [.agent-docs/ai-tooling.md](.agent-docs/ai-tooling.md).

    **Optional:** store raw tokens in `.secrets/` (gitignored) and export from there, e.g. `export GITHUB_MCP_TOKEN=$(cat .secrets/github-mcp-token)`.

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

**Further reading:**

- [.agent-docs/commands.md](.agent-docs/commands.md) — full command reference and direct Docker fallbacks
- [.agent-docs/operations.md](.agent-docs/operations.md) — ports, troubleshooting, CI overview
