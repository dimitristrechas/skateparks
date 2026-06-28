# skateparks.gr

### How to set up the development environment

1. `git clone https://github.com/dimitristrechas/skateparks.git`
2. `cd skateparks`
3. Get the key files from a team member (`config/credentials/development.key`, `config/credentials/production.key`, `config/credentials/test.key`)
4. Copy .env.example to .env and .env.test and fill variables, for RAILS_MASTER_KEY use `config/credentials/development.key` and `config/credentials/test.key` respectively
5. `bundle install`
6. `corepack enable && pnpm install`
7. `lefthook install` (sets up pre-commit hooks)
8. `./scripts.sh`, select option "Fresh build & start development server" to build the docker containers from scratch
9. Open browser on `localhost:3002`
10. Optionally seed the database with "Seed the database" option in `./scripts.sh`
11. Optionally set MCP token environment variables in shell profile (~/.zshrc or ~/.bashrc):
    - `export GITHUB_MCP_TOKEN=<your-token>`
    - `export LINEAR_MCP_TOKEN=<your-token>`

    All AI tools (Cursor, Claude Code, OpenCode) read these env vars. Config files that must stay in sync: `opencode.json`, `.mcp.json`, and `.cursor/mcp.json`. See [.agent-docs/ai-tooling.md](.agent-docs/ai-tooling.md).

    **Optional:** store raw tokens in `.secrets/` (gitignored) and export from there, e.g. `export GITHUB_MCP_TOKEN=$(cat .secrets/github-mcp-token)`.

### How to run tests

1. `./scripts.sh`
2. Select option "Fresh build & start test server" to build the docker containers from scratch
3. Select option "Run tests" to run the test suite

**Note**: This project uses Minitest (Rails default). See [docs/minitest-implementation.md](docs/minitest-implementation.md) for detailed testing guide.
