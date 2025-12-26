## Code Quality Standards

- **All code must include RSpec tests** (use rspec-test-writer agent)
- **Zero RuboCop violations** (use rubocop-enforcer agent)
- **Zero Herb lint and format violations** (use frontend-expert agent)
- Verify compliance: `sh scripts.sh` options in "Tests & Linting & Formatting"
- **Pre-commit hook** blocks commits with RuboCop/Herb/Prettier errors

## Pre-commit Hook (Lefthook)

Runs automatically on `git commit`:

- **rubocop**: Checks staged `*.rb` files
- **herb-lint**: Lints staged `*.erb` files
- **herb-format**: Checks formatting of staged `*.erb` files
- **prettier**: Checks staged `*.{js,css,json,md}` files

## Specialized Agents

Available in `.claude/agents/` for Claude Code and in `.github/agents` GitHub Copilot:

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

**Testing:**

8. Start test server
9. Fresh build & start test
10. Test console
11. Test logs
12. RSpec with coverage

**Code Quality:**

13. Brakeman security scan
14. Check Herb format
15. Run Herb format
16. Check Herb lint
17. Run Herb lint auto-fix
18. Check RuboCop errors
19. Run RuboCop auto-fix
20. Check Prettier errors
21. Run Prettier

**Database:**

22. Seed database
23. Reset & migrate
24. Clear Rails cache

**Other:**

25. Stop Docker containers
26. Show Docker status

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

- **Rails 8.0** + **Ruby 3.3.6** + PostgreSQL
- **Propshaft** (asset pipeline) + **Importmap**
- **Hotwire**: Turbo + Stimulus
- **Tailwind CSS 4.0** + Flowbite
- **ViewComponent**: Component-based views
- **Sidekiq** + **Sidekiq-Cron**: Background jobs + scheduling
- **Redis 5.0**: Caching + Sidekiq backend
- **Cloudinary**: Image storage/processing (ActiveStorage)
- **Kaminari**: Pagination
- **Mobility**: I18n (Greek/English) + ActionText integration
- **Countries**: Country/subdivision data
- **Sitemap Generator**: SEO sitemaps

### Testing Infrastructure

- **RSpec 8.0**: Test framework
- **FactoryBot**: Test data factories
- **Faker**: Realistic fake data
- **Capybara**: System/feature tests
- **Rails Controller Testing**: Controller specs
- **SimpleCov**: Coverage reports
- **RuboCop**: Style enforcement (Rails, RSpec, FactoryBot, Capybara, RSpec Rails)
- **Brakeman**: Security scanning
- **Herb Tools**: ERB linting + formatting
- **Prettier**: JS/CSS/JSON/MD formatting
- **Lefthook**: Git hooks

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
