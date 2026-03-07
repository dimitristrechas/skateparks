# AGENTS.md

Rails 8.0 skatepark directory app (Ruby 3.3.6, PostgreSQL 17, Hotwire, Tailwind 4.0).

## Rules

- Do not commit unless explicitly instructed
- All code must pass linting (RuboCop, Herb, Prettier)
- All code must include Minitest tests — **always run via Docker:**
  ```bash
  docker compose -f docker-compose.test.yml exec skateparks-web-test bin/rails test
  ```

## Reference

- Commands: [.agent-docs/commands.md](.agent-docs/commands.md)
- Conventions: [.agent-docs/conventions.md](.agent-docs/conventions.md)
- Testing guide: [docs/minitest-implementation.md](docs/minitest-implementation.md)
