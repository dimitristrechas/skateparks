# AGENTS.md - Agentic Coding Guide

## Running Tests (Docker required)

```bash
# All tests with coverage
docker compose -f docker-compose.test.yml exec skateparks-web-test bash -c "COVERAGE=true bundle exec rspec"

# Single test file
docker compose -f docker-compose.test.yml exec skateparks-web-test bundle exec rspec spec/models/skatepark_spec.rb

# Single test by line number
docker compose -f docker-compose.test.yml exec skateparks-web-test bundle exec rspec spec/models/skatepark_spec.rb:5
```

## Linting & Formatting

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

## Development Server

```bash
sh scripts.sh  # Interactive menu for all operations
docker compose -f docker-compose.development.yml up -d
docker compose -f docker-compose.development.yml exec skateparks-web bundle exec rails console
```

## Pre-commit Hooks (Lefthook)

Auto-runs on `git commit` with auto-fix:

- RuboCop: `*.rb` files
- Herb lint/format: `*.erb` files
- Prettier: `*.{js,ts,json,css}` files
- Brakeman: runs on `git push`

## Ruby Style (RuboCop)

```ruby
# Single quotes unless interpolation
name = 'skatepark'
greeting = "Hello, #{name}"

# Trailing commas in multiline
STATUSES = [
  :draft,
  :published,
]

# Limits: 120 line length, 25 method length, 20 ABC size
# No frozen_string_literal or class docs required
```

## RSpec Conventions

```ruby
require 'rails_helper'

RSpec.describe Skatepark do
  let(:skatepark) { build(:skatepark) }  # build() unsaved, create() persisted

  describe 'validations' do
    it 'requires name' do
      skatepark.name = nil
      expect(skatepark.save).to be false
    end
  end
end
# Limits: 5 expectations/example, 10 lines/example, 5 nested groups
```

## ERB/Views (Herb)

- Indent: 2 spaces, line length: 120 max
- Tailwind classes auto-sorted
- No duplicate IDs or attributes

## JavaScript (Stimulus)

```javascript
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["element"];
  static values = { url: String };
  connect() {}
  handleClick = (event) => {}; // arrow functions for handlers
}
```

## Prettier (JS/CSS/JSON)

Print width: 120, tab: 2, semicolons, double quotes, trailing comma: es5

## Models

- Mobility for i18n: `translates :name, type: :string`
- ActionText: `translates :description, backend: :action_text`
- Cache invalidation in `after_save`/`after_destroy`
- Enums: `enum :status, { draft: 0, published: 1 }`

## Controllers

- `before_action` for shared setup
- `Rails.cache.fetch('key', expires_in: 1.year)`
- Strong params: `params.expect(model: [:field])`

## ViewComponents

```ruby
class ButtonComponent < ViewComponent::Base
  def initialize(title:, form:, type:)
    super
    @title, @form, @type = title, form, type
  end
end
```

## Factories (FactoryBot)

```ruby
FactoryBot.define do
  factory :skatepark do
    sequence(:name_en) { |n| "Skatepark #{n}" }
    status { :published }
    trait :draft do
      status { :draft }
    end
  end
end
```

## Specialized Agents

In `.claude/agents/` or `.github/agents/`:

- **rspec-test-writer**: RSpec tests, FactoryBot
- **rubocop-enforcer**: RuboCop compliance
- **frontend-expert**: Stimulus, Tailwind, ViewComponents, Herb
- **rails-backend-architect**: Models, controllers, services, DB
- **gem-dependency-manager**: Dependency updates, security

## Tech Stack

Rails 8.0, Ruby 3.3.6, PostgreSQL 17, Hotwire (Turbo + Stimulus), Tailwind CSS 4.0, Flowbite, ViewComponent, Sidekiq + Redis, Cloudinary, Mobility (i18n), Kaminari (pagination), ISO3166 (countries)

## Rules

- Do not commit unless explicitly instructed
- All code must pass RuboCop, Herb lint/format, Prettier checks
- All code must include RSpec tests
- Verify with `sh scripts.sh` before committing
