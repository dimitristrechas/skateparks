# Minitest Testing Guide

Rails 8.1 — Minitest (Rails default). Assert-style. **All tests must run via Docker.**

---

## Table of Contents

1. [Test Structure](#test-structure)
2. [Test Data](#test-data)
3. [Writing Tests](#writing-tests)
4. [Authentication in Tests](#authentication-in-tests)
5. [Common Patterns](#common-patterns)
6. [Running Tests](#running-tests)
7. [Troubleshooting](#troubleshooting)

---

## Test Structure

### Directory Layout

```
test/
├── channels/           # ActionCable tests
│   └── application_cable/
│       ├── channel_test.rb
│       └── connection_test.rb
├── components/         # ViewComponent tests
├── controllers/        # Controller integration tests
├── factories/          # FactoryBot factory definitions
│   ├── skateparks.rb
│   ├── users.rb
│   └── popular_skateparks.rb
├── fixtures/           # Fixtures for users + audit_logs only
│   └── files/         # Sample images for file upload tests
├── helpers/            # ActionView helper tests
├── jobs/               # ActiveJob tests
├── mailers/            # ActionMailer tests
├── models/             # Model unit tests
├── support/            # Support helpers autoloaded from test/support/**/*.rb
│   └── form_builder_double.rb
├── system/             # Capybara system tests (no tests written yet)
├── workers/            # Sidekiq worker tests
└── test_helper.rb
```

### Base Classes

| Test type      | Base class                        |
| -------------- | --------------------------------- |
| Models         | `ActiveSupport::TestCase`         |
| Controllers    | `ActionDispatch::IntegrationTest` |
| ViewComponents | `ViewComponent::TestCase`         |
| Workers        | `ActiveSupport::TestCase`         |
| Jobs           | `ActiveSupport::TestCase`         |
| Helpers        | `ActionView::TestCase`            |
| Mailers        | `ActionMailer::TestCase`          |

### File Naming

| Type       | Pattern                                 | Example                          |
| ---------- | --------------------------------------- | -------------------------------- |
| Model      | `test/models/*_test.rb`                 | `skatepark_test.rb`              |
| Controller | `test/controllers/*_controller_test.rb` | `skateparks_controller_test.rb`  |
| Component  | `test/components/*_component_test.rb`   | `button_component_test.rb`       |
| Worker     | `test/workers/*_test.rb`                | `session_cleanup_worker_test.rb` |
| Job        | `test/jobs/*_test.rb`                   | `sitemap_worker_test.rb`         |
| Helper     | `test/helpers/*_helper_test.rb`         | `schema_helper_test.rb`          |

---

## Test Data

### Factories (primary — use for most tests)

Factories live in `test/factories/`. Included in all test classes via `FactoryBot::Syntax::Methods`.

```ruby
# Build — no DB hit (prefer for validation tests)
skatepark = build(:skatepark)

# Create — persists to DB
skatepark = create(:skatepark)

# With attributes
skatepark = create(:skatepark, name_en: 'Custom Name', country_code: 'US')

# With traits
draft_park    = create(:skatepark, :draft)
archived_park = create(:skatepark, :archived)
us_park       = create(:skatepark, :us_location)
us_draft      = create(:skatepark, :draft, :us_location)

# Users
admin       = create(:user, :admin)
banned_user = create(:user, :banned)

# Popular skateparks
popular = create(:popular_skatepark)
```

### Available Factories and Traits

| Factory              | Traits                                |
| -------------------- | ------------------------------------- |
| `:skatepark`         | `:draft`, `:archived`, `:us_location` |
| `:user`              | `:admin`, `:banned`                   |
| `:popular_skatepark` | —                                     |

The `:skatepark` factory attaches real fixture images (`test/fixtures/files/sample_image{1,2,3}.jpg`) for `cover_image` and `images`.

### Fixtures (users + audit_logs only)

Rails fixtures exist for `users` and `audit_logs`. Access via `users(:one)`, `audit_logs(:one)`. All other models use factories.

---

## Writing Tests

### Naming Styles

Both are valid and used in this codebase:

```ruby
# Method-name style
def test_requires_name_to_be_present
  ...
end

# String-description style
test 'requires name to be present' do
  ...
end
```

### Model Tests

```ruby
require 'test_helper'

class SkateparkTest < ActiveSupport::TestCase
  def setup
    @skatepark = build(:skatepark)
  end

  def test_requires_name_to_be_present
    @skatepark.name_en = nil
    assert_not @skatepark.save
  end

  def test_generates_slug_on_save
    skatepark = create(:skatepark, name_en: 'Test Park')
    assert_equal 'test-park', skatepark.slug
  end

  def test_validates_format
    @skatepark.country_code = 'invalid'
    assert_not @skatepark.save
    assert_includes @skatepark.errors[:country_code], 'is invalid'
  end
end
```

### Controller Tests

```ruby
require 'test_helper'

class SkateparksControllerTest < ActionDispatch::IntegrationTest
  def setup
    @skatepark = create(:skatepark)
  end

  def test_index_returns_success
    get root_path
    assert_response :success
  end

  def test_filters_by_country_code
    greece = create(:skatepark, country_code: 'GR')
    usa    = create(:skatepark, country_code: 'US')

    get skateparks_path(country_code: 'US')

    assert_includes assigns(:skateparks), usa
    assert_not_includes assigns(:skateparks), greece
  end

  def test_turbo_stream_response
    get skateparks_path, as: :turbo_stream
    assert_response :success
    assert_match(/turbo-stream/, response.content_type)
  end
end
```

### Component Tests

```ruby
require 'test_helper'

class ButtonComponentTest < ViewComponent::TestCase
  def test_renders_primary_variant
    render_inline(ButtonComponent.new(variant: :primary)) { 'Click me' }
    assert_selector 'button', text: 'Click me'
  end
end
```

Components that call route helpers require a `with_request_url` block:

```ruby
def test_renders_skatepark_link
  with_request_url '/' do
    render_inline(HomepageSkateparkCardComponent.new(skatepark: create(:skatepark)))
    assert_selector 'a[href]'
  end
end
```

### Worker Tests

```ruby
require 'test_helper'

class SessionCleanupWorkerTest < ActiveSupport::TestCase
  def test_deletes_expired_sessions
    expired = create(:session, expires_at: 1.day.ago)
    active  = create(:session, expires_at: 2.weeks.from_now)

    SessionCleanupWorker.new.perform

    assert_not Session.exists?(expired.id)
    assert Session.exists?(active.id)
  end
end
```

---

## Authentication in Tests

Controller tests that require a logged-in user use `login_as`, defined on `ActionDispatch::IntegrationTest` in `test_helper.rb`.

```ruby
class Admin::UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @admin = create(:user, :admin)
    login_as(@admin)
  end

  def test_requires_admin
    login_as(create(:user))  # Regular user
    get admin_users_path
    assert_redirected_to root_path
  end

  def test_unauthenticated_redirect
    # No login_as call — request goes as guest
    delete session_path
    get admin_users_path
    assert_redirected_to new_session_path
  end
end
```

**How it works**: `login_as` creates a real `Session` record, builds a properly signed cookie, and injects it into the test request context via `cookies[:session_token]`. It is only available on `ActionDispatch::IntegrationTest`.

---

## Common Patterns

### Assertions Reference

```ruby
# Equality
assert_equal expected, actual
assert_not_equal expected, actual

# Truthiness
assert value            # truthy
refute value            # falsy (alias: assert_not)
assert_nil value
assert_not_nil value

# Collections
assert_empty collection
assert_includes collection, item
assert_not_includes collection, item

# Strings / Regex
assert_match /pattern/, string
assert_no_match /pattern/, string

# HTTP responses (controller tests)
assert_response :success               # 200
assert_response :redirect              # 3xx
assert_response :not_found             # 404
assert_response :unprocessable_content # 422
assert_redirected_to some_path

# DB changes
assert_difference 'Model.count', 1 do
  post create_path, params: valid_params
end

assert_no_difference 'Model.count' do
  post create_path, params: invalid_params
end

# Email
assert_emails 1 do
  post password_resets_path, params: { email_address: user.email_address }
end

# Exceptions
assert_raises(ActiveRecord::RecordInvalid) { record.save! }

# Selectors (component tests)
assert_selector 'h1', text: 'Welcome'
assert_no_selector '.error-message'
```

### Mocking with Mocha

Mocha is the primary mocking library (`require 'mocha/minitest'` in `test_helper.rb`).

```ruby
# Stub instance method on all instances
SomeClass.any_instance.stubs(:method_name).returns(value)

# Stub class method
Rails.stubs(:env).returns(ActiveSupport::StringInquirer.new('production'))

# Expect (test fails if not called)
Rails.cache.expects(:delete).with('skateparks_popular').once

# Stub with dynamic return
Rake::Task.expects(:[]).with('sitemap:refresh:no_ping').returns(
  mock.tap { |m| m.expects(:invoke) }
)
```

### Caching

Cache is active in tests (`:memory_store`). Clear it in `setup` when your test involves cached data:

```ruby
def setup
  Rails.cache.clear
  @skatepark = create(:skatepark)
end

def test_caches_result_after_first_request
  get root_path
  assert_not_nil Rails.cache.read('skateparks_latest')
end

def test_cache_invalidated_on_publish
  # Populate cache
  get root_path

  @skatepark.update!(status: :published)

  assert_nil Rails.cache.read('skateparks_latest')
end
```

### File Uploads

Use `fixture_file_upload` in test methods. Use `Rack::Test::UploadedFile` in factory definitions (factories run outside request context):

```ruby
# In a test method — fixture_file_upload is available
def test_requires_cover_image
  skatepark = build(:skatepark)
  skatepark.cover_image = nil
  assert_not skatepark.save
end

def test_rejects_single_image
  skatepark = build(:skatepark, images: [fixture_file_upload('sample_image1.jpg')])
  assert_not skatepark.save   # Requires at least 2 images
end
```

### Testing Validations (AAA pattern)

```ruby
def test_requires_email_address
  # Arrange
  user = build(:user, email_address: nil)

  # Act
  result = user.save

  # Assert
  assert_not result
  assert_includes user.errors[:email_address], "can't be blank"
end
```

---

## Running Tests

**Always run via Docker** (tests require the test container):

```bash
# All tests
docker compose -f docker-compose.test.yml exec skateparks-web-test bin/rails test

# All tests with coverage report
docker compose -f docker-compose.test.yml exec skateparks-web-test bash -c "COVERAGE=true bin/rails test"

# Single file
docker compose -f docker-compose.test.yml exec skateparks-web-test bin/rails test test/models/skatepark_test.rb

# Single test by line number
docker compose -f docker-compose.test.yml exec skateparks-web-test bin/rails test test/models/skatepark_test.rb:42

# Single test by name
docker compose -f docker-compose.test.yml exec skateparks-web-test bin/rails test test/models/skatepark_test.rb -n test_requires_name_to_be_present
```

Or use the interactive menu:

```bash
./scripts.sh   # → "Run tests"
```

---

## Troubleshooting

### "Factory not registered"

`KeyError: Factory not registered: "skatepark"`

1. Check file exists: `test/factories/skateparks.rb`
2. Check factory name matches: `factory :skatepark do`
3. Restart the test container if running in Docker

### "Cannot generate URL for attachment"

`Cannot generate URL for sample_image.jpg using Disk service`

Already configured. If this surfaces:

1. Check `config/environments/test.rb` has the middleware that sets `ActiveStorage::Current.url_options`
2. Confirm the request or test path is running through the test environment middleware stack

### `fixture_file_upload` undefined in factory

Using `fixture_file_upload` inside a factory definition. Factories don't run in a test request context. Use `Rack::Test::UploadedFile` instead:

```ruby
# In factory — use this
cover_image { Rack::Test::UploadedFile.new(Rails.root.join('test/fixtures/files/sample.jpg'), 'image/jpeg') }

# In test method — this is fine
build(:skatepark, images: [fixture_file_upload('sample_image1.jpg')])
```

### Tests pass alone, fail in full suite

Database state leaking or cache not cleared. Check:

1. `use_transactional_tests = true` in `test_helper.rb` (already set)
2. Call `Rails.cache.clear` in `setup` if your test depends on cache state
3. Write assertions against behavior, not exact collection state:

```ruby
# Fragile — assumes DB is empty
assert_equal [@skatepark], Skatepark.published.to_a

# Robust — tests membership, not exact state
assert_includes Skatepark.published, @published_skatepark
assert_not_includes Skatepark.published, @draft_skatepark
```

### `login_as` undefined

`login_as` is only available on `ActionDispatch::IntegrationTest` (controller tests). It is not on `ActiveSupport::TestCase` — model and worker tests don't need it.

---

## Test Gems

| Gem                        | Purpose                                                                 |
| -------------------------- | ----------------------------------------------------------------------- |
| `factory_bot_rails`        | Test data factories                                                     |
| `faker`                    | Random test data                                                        |
| `mocha`                    | Mocking and stubbing                                                    |
| `rails-controller-testing` | `assigns(:var)` in controller tests                                     |
| `capybara`                 | System test browser automation (installed; no system tests written yet) |
