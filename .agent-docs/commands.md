# Commands Reference

`sh scripts.sh` is the preferred entry point for starting development and test servers and for common lint/format/test workflows. Use the direct commands below when `scripts.sh` does not cover the task or when automation needs a non-interactive command.

## Linting

```bash
bundle exec rubocop                 # Check Ruby
bundle exec rubocop -A              # Auto-fix Ruby
yarn herb:lint                      # Lint ERB
yarn herb:lint --fix                # Fix ERB lint
yarn herb:format                    # Format ERB
yarn prettier:check                 # Check JS/CSS/JSON
yarn prettier:fix                   # Fix JS/CSS/JSON
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
