# skateparks.gr

### How to set up the development environment

1. `git clone https://github.com/dimitristrechas/skateparks.git`
2. `cd skateparks`
3. Get the key files from a team member (`config/credentials/development.key`, `config/credentials/production.key`, `config/credentials/test.key`)
4. Copy .env.example to .env and .env.test and fill variables, for RAILS_MASTER_KEY use `config/credentials/development.key` and `config/credentials/test.key` respectively
5. `bundle install`
6. `yarn`
7. `lefthook install` (sets up pre-commit hooks)
8. `./scripts.sh`, select option "Fresh build & start development server" to build the docker containers from scratch
9. Open browser on `localhost:3000`
10. Optionally seed the database with "Seed the database" option in `./scripts.sh`

### MCP Secrets (OpenCode)

MCP integrations in `opencode.json` use tokens stored in `.secrets/`:
1. `mkdir .secrets`
2. Add token files (raw token, no extension):
   - `.secrets/github-mcp-token`
   - `.secrets/linear-token`
3. Folder is gitignored

### How to run tests

1. `./scripts.sh`
2. Select option "Fresh build & start test server" to build the docker containers from scratch
3. Select option "Run RSpec tests" to run the specs
