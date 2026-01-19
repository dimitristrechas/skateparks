# Commands Reference

## Testing (Docker)

```bash
# All tests with coverage
docker compose -f docker-compose.test.yml exec skateparks-web-test bash -c "COVERAGE=true bundle exec rspec"

# Single file
docker compose -f docker-compose.test.yml exec skateparks-web-test bundle exec rspec spec/models/skatepark_spec.rb

# Single test by line
docker compose -f docker-compose.test.yml exec skateparks-web-test bundle exec rspec spec/models/skatepark_spec.rb:5
```

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
```

## Development

```bash
sh scripts.sh  # Interactive menu (recommended)
docker compose -f docker-compose.development.yml up -d
docker compose -f docker-compose.development.yml exec skateparks-web bundle exec rails console
```
