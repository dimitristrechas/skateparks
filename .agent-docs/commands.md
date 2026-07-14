# Commands Reference

`sh scripts.sh` is the preferred entry point for starting development and test servers and for common lint/format/test workflows. For automation, use non-interactive subcommands (see below). Use the direct commands when `scripts.sh` does not cover the task.

## scripts.sh (non-interactive)

```bash
sh scripts.sh                              # Interactive menu
sh scripts.sh test                           # All tests with coverage
sh scripts.sh test --fast                    # All tests without coverage
sh scripts.sh test test/models/foo_test.rb   # Single file or line
sh scripts.sh lint                           # Fast linter checks (parallel RuboCop, Herb, Prettier)
sh scripts.sh lint --full                    # Includes Zeitwerk check
sh scripts.sh lint --fix                     # Auto-fix then re-check
sh scripts.sh security                       # Brakeman, bundle-audit, pnpm audit (parallel)
sh scripts.sh ci                             # Full CI parity (all checks in parallel)
sh scripts.sh dev up                         # Start development server
sh scripts.sh dev rebuild --force            # Rebuild development containers
sh scripts.sh test-server up                 # Start test server
sh scripts.sh test-server schema-load        # Reload test DB schema
```

## Linting

```bash
bundle exec rubocop --force-exclusion       # Check Ruby
bundle exec rubocop -A --force-exclusion    # Auto-fix Ruby
pnpm herb:lint                      # Lint ERB
pnpm herb:lint --fix                # Fix ERB lint
pnpm herb:format                    # Format ERB
pnpm prettier:check                 # Check JS/CSS/JSON
pnpm prettier:fix                   # Fix JS/CSS/JSON
bundle exec brakeman -q --no-pager  # Security scan
bundle exec bundle-audit check --update  # Gem vulnerability scan
```

`bundle exec rubocop` includes `rubocop-rails` and can flag user-visible string literals in Ruby (e.g. `Rails/I18nLocaleTexts` where enabled). Fix by moving copy to `I18n.t` / locale YAML.

## Tests (verify i18n, components, query load)

All tests run via Docker (see [docs/minitest-implementation.md](../docs/minitest-implementation.md)).

```bash
docker compose -f docker-compose.test.yml exec skateparks-web-test bin/rails test
```

- After changing **controllers** that load lists or show pages, run the relevant **controller tests** and watch for N+1 regressions; use `assert_queries` in a focused test when guarding a known-hot path (see minitest guide).
- After changing **views/components**, run **component** and **helper** tests under `test/components` and `test/helpers`.

## Development

```bash
sh scripts.sh  # Interactive menu (recommended)
docker compose -f docker-compose.development.yml up -d
docker compose -f docker-compose.development.yml exec skateparks-web bundle exec rails console
```
