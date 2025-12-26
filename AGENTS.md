## Code Quality Standards

- **All code must include RSpec tests** (use rspec-test-writer agent)
- **Zero RuboCop violations** (use rubocop-enforcer agent)
- Verify compliance: `sh scripts.sh` option 14 or 15
- **Pre-commit hook** blocks commits with RuboCop/Herb/Prettier errors

## Pre-commit Hook (Lefthook)

Runs automatically on `git commit`:

- **rubocop**: Checks staged `*.rb` files
- **herb-lint**: Lints staged `*.erb` files
- **herb-format**: Checks formatting of staged `*.erb` files
- **prettier**: Checks staged `*.{js,css,json,md}` files

## Specialized Claude Agents

Available in `.claude/agents/`:

- **rspec-test-writer**: Writing/debugging RSpec tests, FactoryBot factories
- **rubocop-enforcer**: RuboCop compliance checking and auto-fixing
- **frontend-expert**: Stimulus controllers, Tailwind CSS, ViewComponents
- **rails-backend-architect**: Models, controllers, services, database design
- **gem-dependency-manager**: Dependency updates, security audits

## Development Commands (`sh scripts.sh`)

**Server:**

1. Start dev server
2. Fresh build & start
3. Attach to server
4. Rails console
5. Docker console
6. View logs
7. Stop server

**Testing:** 8. Start test server 9. Fresh build & start test 10. Test console 11. Test logs 12. RSpec with coverage

**Code Quality:** 13. Format ERB 14. Run RuboCop 15. RuboCop auto-fix 16. Prettier (JS/CSS)

**Database:** 17. Seed database 18. Reset & migrate 21. Clear Rails cache

## Architecture

### Models

- **Skatepark**: Main entity with i18n (Greek/English via Mobility gem)
  - Location: lat/lng, country_code, state (ISO3166 gem)
  - Images: Cloudinary (cover_image + multiple attachments)
  - Rich text: ActionText descriptions
  - Status: draft/published/archived enum
  - URLs: Friendly slug-based

- **PopularSkatepark**: Featured skateparks with position ordering
  - belongs_to :skatepark, uniqueness validation
  - Cache invalidation on save/destroy
  - Default scope ordered by position

### Controllers

- **SkateparksController**: Public listing/detail, filtering by country/state
- **HomeController**: Static pages (about, contact)
- **Admin::SkateparksController**: Admin CRUD
- **Admin::PopularSkateparksController**: Featured skateparks management
- **Admin::DashboardController**: Admin dashboard

### Views & Components

**ViewComponents** (app/components/):

- ButtonComponent
- LinkComponent
- SkateparkCardComponent
- TextFieldComponent

**Stimulus Controllers** (app/javascript/controllers/):

- header_controller.js
- skatepark_controller.js
- admin/skateparks/form_controller.js
- skateparks/filters_controller.js

### Helpers

- **LocaleHelper**: I18n utilities, country/state names with flags
- **SchemaHelper**: JSON-LD structured data for SEO
- **SkateparksHelper**: Skatepark-specific view helpers

### Tech Stack

- **Rails 8.0** + PostgreSQL
- **Propshaft** (asset pipeline)
- **Hotwire**: Turbo + Stimulus
- **Tailwind CSS 4.0** + Flowbite
- **Sidekiq**: Background jobs + cron
- **Cloudinary**: Image storage/processing
- **Kaminari**: Pagination
- **Mobility**: I18n (Greek/English)
- **ISO3166**: Country/subdivision data

### Testing Infrastructure

- **RSpec 8.0**: Test framework
- **FactoryBot**: Test data factories
- **Faker**: Realistic fake data
- **Capybara**: System/feature tests
- **SimpleCov**: Coverage reports
- **RuboCop**: Style enforcement (Rails, RSpec, FactoryBot, Capybara)

Factories in `spec/factories/`: skateparks.rb, popular_skateparks.rb
Shared contexts: `spec/support/shared_contexts/admin_auth.rb`

### Data Flow

- Published skateparks only on public pages
- Country/state filtering with caching
- Redis caching for popular skateparks list
- SEO meta tags per skatepark with structured data
- Emoji flags for location-friendly names

## Environment Setup

1. Clone repo
2. Get credentials: `config/credentials/{development,production,test}.key`
3. Copy `.env.example` → `.env` + `.env.test`, set RAILS_MASTER_KEY
4. `bundle install && yarn install`
5. `sh scripts.sh` option 2 (fresh build)
6. Open `localhost:3000`
7. Optional: seed database (option 17)

**Docker-first workflow**: All ops via `scripts.sh` interactive menu.
