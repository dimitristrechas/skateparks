# Draft: RSpec to Minitest Migration

## User Goal

Migrate from RSpec to Minitest to reduce test execution time, simplify test code, and remove RSpec-related gems.

## Current Test Setup (Confirmed)

**RSpec gems in use:**

- rspec-rails ~> 8.0
- rubocop-rspec (linting)
- rubocop-rspec_rails (linting)

**Test support gems:**

- factory_bot_rails (fixtures)
- capybara (system tests)
- faker (test data)
- rails-controller-testing (controller tests)
- simplecov (coverage)

**Test types found:**

- Model tests: 20 specs
- Controller tests (admin + public)
- Component tests (ViewComponent)
- System tests (Capybara)
- Job/Worker tests
- Helper tests
- Mailer/Channel tests

**Test infrastructure:**

- Docker-based test execution required
- SimpleCov coverage tracking configured
- FactoryBot configured in spec/support/factory_bot.rb
- Shared contexts in spec/support/
- Pre-commit hooks run linting

## Technical Decisions

**Why Minitest:**

- Built into Rails (no extra gem)
- Faster boot time
- Simpler syntax
- Rails 8 defaults to Minitest

**Migration Strategy:**

- Convert all spec files to test files
- Translate RSpec syntax to Minitest assertions
- Keep FactoryBot (works with Minitest)
- Keep Capybara (works with Minitest)
- Remove RSpec gems after migration complete

## Scope Boundaries

**INCLUDE:**

- All test files conversion (models, controllers, components, system)
- Test helper migration
- Gemfile cleanup (remove RSpec gems)
- RuboCop config update (remove RSpec cops)
- Docker test setup updates
- SimpleCov integration with Minitest

**EXCLUDE:**

- Test data changes (keep existing factories)
- Business logic changes
- New test coverage additions
- CI/CD pipeline changes (focus on local Docker setup)

## Decisions (Confirmed)

1. **Syntax**: Classic Minitest (test* methods, assert*\* syntax)
2. **Approach**: All at once migration
3. **Coverage**: Native Ruby coverage (remove SimpleCov)
4. **ViewComponent**: Minitest ViewComponent integration

## Test Conversion Patterns

**RSpec → Minitest mapping:**

- `describe X` → `class XTest < ActiveSupport::TestCase`
- `it "does thing"` → `def test_does_thing`
- `expect(x).to eq(y)` → `assert_equal y, x`
- `expect(x).to be_truthy` → `assert x`
- `expect(x).to be false` → `assert_equal false, x`
- `let(:var) { value }` → `setup { @var = value }`
- `before { ... }` → `setup { ... }`
- `aggregate_failures` → remove (Minitest shows all failures by default)
- `create(:factory)` → unchanged (FactoryBot works same)

**Controller tests:**

- `RSpec.describe XController` → `class XControllerTest < ActionDispatch::IntegrationTest`
- Controller specs need migration to integration-style tests

**Component tests:**

- `RSpec.describe XComponent, type: :component` → `class XComponentTest < ViewComponent::TestCase`
- `render_inline(component)` → unchanged (ViewComponent API same)
- `have_button(...)` Capybara matcher → unchanged
