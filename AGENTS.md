# AGENTS.md

Rails 8.0 skatepark directory app (Ruby 3.3.6, PostgreSQL 17, Hotwire, Tailwind 4.0).

## Quick Reference

```bash
sh scripts.sh                       # Interactive menu (dev, test, lint)

# Run tests (MUST use Docker - local will fail)
docker compose -f docker-compose.test.yml exec skateparks-web-test bin/rails test test/path/to_test.rb

# Linting (can run locally)
bundle exec rubocop -A              # Auto-fix Ruby
yarn herb:lint --fix && yarn herb:format  # Fix ERB
```

See [commands.md](.agent-docs/commands.md) for full Docker commands.

## Rules

- Do not commit unless explicitly instructed
- All code must pass linting (RuboCop, Herb, Prettier)
- All code must include Minitest tests (see [docs/minitest-implementation.md](docs/minitest-implementation.md))

## Conventions

Project-specific patterns: [conventions.md](.agent-docs/conventions.md)
