# Minitest Implementation Guide

**Project**: skateparks.gr  
**Rails Version**: 8.0  
**Migration**: RSpec → Minitest  
**Date**: February 2026

---

## Table of Contents

1. [What is Minitest?](#what-is-minitest)
2. [RSpec vs Minitest](#rspec-vs-minitest)
3. [Migration Changes Made](#migration-changes-made)
4. [Test Structure](#test-structure)
5. [Writing Tests](#writing-tests)
6. [Running Tests](#running-tests)
7. [Common Patterns](#common-patterns)
8. [Troubleshooting](#troubleshooting)

---

## What is Minitest?

Minitest is Rails' default testing framework. It's:

- **Built into Ruby** - No external dependencies needed
- **Fast** - Minimal overhead, quick test runs
- **Simple** - Plain Ruby classes and methods
- **Flexible** - Supports both assert-style and spec-style syntax

We use **assert-style** (the default), which looks like standard Ruby code.

---

## RSpec vs Minitest

### RSpec (Before)

```ruby
# spec/models/skatepark_spec.rb
RSpec.describe Skatepark do
  describe '#save' do
    context 'when name is nil' do
      it 'returns false' do
        skatepark = build(:skatepark)
        skatepark.name = nil
        expect(skatepark.save).to eq(false)
      end
    end
  end
end
```

### Minitest (After)

```ruby
# test/models/skatepark_test.rb
class SkateparkTest < ActiveSupport::TestCase
  def test_requires_name_to_be_present
    skatepark = build(:skatepark)
    skatepark.name = nil
    assert_equal false, skatepark.save
  end
end
```

### Key Differences

| Aspect              | RSpec                         | Minitest                                 |
| ------------------- | ----------------------------- | ---------------------------------------- |
| **File Location**   | `spec/`                       | `test/`                                  |
| **File Naming**     | `*_spec.rb`                   | `*_test.rb`                              |
| **Class Style**     | `RSpec.describe`              | `class MyTest < ActiveSupport::TestCase` |
| **Test Definition** | `it "does something"`         | `def test_does_something`                |
| **Assertions**      | `expect(x).to eq(y)`          | `assert_equal y, x`                      |
| **Setup**           | `before { }` or `let(:x) { }` | `def setup`                              |
| **Grouping**        | `describe` / `context`        | Method names (convention)                |

---

## Migration Changes Made

### 1. Factory Files Recreated

**Problem**: RSpec factories were deleted but not recreated for Minitest.

**Solution**: Created factories in `test/factories/`

```ruby
# test/factories/skateparks.rb
FactoryBot.define do
  factory :skatepark do
    sequence(:name_en) { |n| "#{Faker::Address.community} Skatepark #{n}" }
    sequence(:name_el) { |n| "#{Faker::Address.community} Σκέιτπαρκ #{n}" }

    lat { Faker::Address.latitude }
    lng { Faker::Address.longitude }
    country_code { 'GR' }
    state { 'I' }

    description_en { Faker::Lorem.paragraph(sentence_count: 3) }
    description_el { Faker::Lorem.paragraph(sentence_count: 3) }

    # File attachments using Rack::Test::UploadedFile
    cover_image do
      Rack::Test::UploadedFile.new(
        Rails.root.join('test/fixtures/files/sample_image2.jpg'),
        'image/jpeg'
      )
    end

    images do
      [
        Rack::Test::UploadedFile.new(
          Rails.root.join('test/fixtures/files/sample_image1.jpg'),
          'image/jpeg'
        ),
        Rack::Test::UploadedFile.new(
          Rails.root.join('test/fixtures/files/sample_image3.jpg'),
          'image/jpeg'
        ),
      ]
    end

    status { :published }

    # Traits for different states
    trait :draft do
      status { :draft }
    end

    trait :archived do
      status { :archived }
    end

    trait :us_location do
      country_code { 'US' }
      state { 'CA' }
    end
  end
end
```

**Key Points**:

- Use `Rack::Test::UploadedFile` for file attachments (NOT `fixture_file_upload` - that's only available in test contexts, not factory contexts)
- Traits allow different variations: `create(:skatepark, :draft)`
- Sequences ensure uniqueness: `name_en` gets incrementing numbers

### 2. Test Helper Configuration

**File**: `test/test_helper.rb`

```ruby
require 'coverage'
Coverage.start(:all)

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'mocha/minitest'

abort('The Rails environment is running in production mode!') if Rails.env.production?

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

Rails.root.glob('test/support/**/*.rb').sort.each { |f| require f }

module ActiveSupport
  class TestCase
    fixtures :all
    self.use_transactional_tests = true
    self.fixture_paths = [Rails.root.join('test/fixtures')]

    include FactoryBot::Syntax::Methods
    include ActionDispatch::TestProcess::FixtureFile
  end
end

module ActionDispatch
  class IntegrationTest
    def before_setup
      super
      ActiveStorage::Current.url_options = {
        host: 'test.host',
        protocol: 'http'
      }
    end
  end
end

Rails.application.routes.default_url_options[:host] = 'http://test.host'
```

**What This Does**:

- **Coverage**: Tracks code coverage for all tests
- **Transactional tests**: Each test runs in a transaction that rolls back (database stays clean)
- **FactoryBot integration**: Allows `create(:skatepark)` instead of `FactoryBot.create(:skatepark)`
- **ActiveStorage URL generation**: Sets URL options so attachment URLs work in tests
- **Test support files**: Loads any helper files from `test/support/`

### 3. ActiveStorage URL Configuration

**Problem**: Tests failed with "Cannot generate URL for sample_image2.jpg using Disk service"

**Solution**: Added middleware in `config/environments/test.rb`

```ruby
# Inside Rails.application.configure block
config.middleware.use(
  Class.new do
    def initialize(app)
      @app = app
    end

    def call(env)
      ActiveStorage::Current.url_options = {
        host: env['HTTP_HOST'] || 'test.host',
        protocol: 'http'
      }
      @app.call(env)
    end
  end
)
```

**Why This is Needed**:

- ActiveStorage needs to know the host to generate URLs for attachments
- In tests, there's no real HTTP host, so we provide a fake one
- This runs for every test request, ensuring URLs always work

### 4. Test Isolation Fixes

**Problem**: Tests expected exact array matches but got different results when running full suite

**Before** (Fragile):

```ruby
def test_get_index_assigns_only_published_skateparks
  get root_path
  assert_equal [@published_skatepark], assigns(:skateparks)
end
```

**After** (Robust):

```ruby
def test_get_index_assigns_only_published_skateparks
  draft_skatepark = create(:skatepark, :draft)
  archived_skatepark = create(:skatepark, :archived)

  get root_path
  skateparks = assigns(:skateparks).to_a

  assert_includes skateparks, @published_skatepark
  assert_not_includes skateparks, draft_skatepark
  assert_not_includes skateparks, archived_skatepark
end
```

**Why This is Better**:

- Doesn't assume database is empty
- Tests behavior (published vs draft/archived) instead of exact state
- Works when running single test or full suite

---

## Test Structure

### Directory Layout

```
test/
├── channels/           # ActionCable channel tests
├── components/         # ViewComponent tests
├── controllers/        # Controller tests
│   ├── admin/         # Admin namespace
│   └── ...
├── factories/          # FactoryBot factories
│   ├── skateparks.rb
│   └── popular_skateparks.rb
├── fixtures/           # Test data (we use factories instead)
│   └── files/         # Sample files for uploads
├── helpers/           # Helper tests
├── jobs/              # ActiveJob tests
├── mailers/           # ActionMailer tests
├── models/            # Model tests
├── system/            # System/integration tests (Capybara)
└── test_helper.rb     # Global test configuration
```

### Test File Naming

| File Type  | Pattern                                 | Example                         |
| ---------- | --------------------------------------- | ------------------------------- |
| Model      | `test/models/*_test.rb`                 | `skatepark_test.rb`             |
| Controller | `test/controllers/*_controller_test.rb` | `skateparks_controller_test.rb` |
| Helper     | `test/helpers/*_helper_test.rb`         | `schema_helper_test.rb`         |
| Job        | `test/jobs/*_test.rb`                   | `sitemap_worker_test.rb`        |
| Component  | `test/components/*_component_test.rb`   | `button_component_test.rb`      |

---

## Writing Tests

### Model Tests

```ruby
require 'test_helper'

class SkateparkTest < ActiveSupport::TestCase
  # Setup runs before each test
  def setup
    @skatepark = build(:skatepark)
  end

  # Test method names must start with "test_"
  def test_requires_name_to_be_present
    @skatepark.name = nil
    assert_equal false, @skatepark.save
  end

  def test_generates_slug_based_on_name
    skatepark = create(:skatepark, name_en: 'Test Skatepark')
    assert_equal 'test-skatepark', skatepark.slug
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

  def test_get_index_returns_success
    get skateparks_path
    assert_response :success
  end

  def test_get_show_assigns_skatepark
    get skatepark_path(@skatepark)
    assert_equal @skatepark, assigns(:skatepark)
  end

  def test_filters_by_country_code
    greece_skatepark = create(:skatepark, country_code: 'GR')
    us_skatepark = create(:skatepark, country_code: 'US')

    get skateparks_path(country_code: 'US')

    assert_includes assigns(:skateparks), us_skatepark
    assert_not_includes assigns(:skateparks), greece_skatepark
  end
end
```

### Component Tests

```ruby
require 'test_helper'

class ButtonComponentTest < ViewComponent::TestCase
  def test_renders_primary_button
    render_inline(ButtonComponent.new(variant: :primary)) { "Click me" }

    assert_selector 'button.btn-primary', text: 'Click me'
  end

  def test_renders_as_link
    render_inline(ButtonComponent.new(href: '/path')) { "Link" }

    assert_selector 'a[href="/path"]', text: 'Link'
  end
end
```

---

## Common Assertions

### Equality & Truthiness

```ruby
assert_equal expected, actual          # Equal values
assert_not_equal expected, actual      # Not equal
assert_same object1, object2           # Same object reference
assert_nil value                       # Value is nil
assert value                           # Value is truthy
refute value                           # Value is falsy
```

### Collections

```ruby
assert_empty collection                # Collection is empty
assert_includes collection, item       # Collection includes item
assert_not_includes collection, item   # Collection doesn't include item
```

### Responses (Controller Tests)

```ruby
assert_response :success              # HTTP 200
assert_response :redirect             # HTTP 3xx
assert_response :not_found            # HTTP 404
assert_response :unprocessable_content # HTTP 422

assert_redirected_to root_path        # Redirected to specific path
```

### Database Changes

```ruby
assert_difference 'Skatepark.count', 1 do
  post skateparks_path, params: valid_params
end

assert_no_difference 'Skatepark.count' do
  post skateparks_path, params: invalid_params
end
```

### Selectors (Component/System Tests)

```ruby
assert_selector 'h1', text: 'Welcome'
assert_selector '.btn-primary'
assert_no_selector '.error-message'
```

---

## Running Tests

### Via Docker (Required for this project)

```bash
# Interactive menu
./scripts.sh
# Select option 12: "Run tests"

# Or directly:
docker compose -f docker-compose.test.yml exec skateparks-web-test bin/rails test
```

### Run Specific Tests

```bash
# Single file
bin/rails test test/models/skatepark_test.rb

# Single test method
bin/rails test test/models/skatepark_test.rb:42

# Pattern matching
bin/rails test test/models/**/*_test.rb
```

### Coverage Report

Tests automatically generate coverage reports:

```
coverage/index.html
```

Open in browser to see line-by-line coverage.

---

## Common Patterns

### Using FactoryBot

```ruby
# Build (doesn't save to database)
skatepark = build(:skatepark)

# Create (saves to database)
skatepark = create(:skatepark)

# With attributes
skatepark = create(:skatepark, name_en: 'Custom Name')

# With traits
draft = create(:skatepark, :draft)
archived = create(:skatepark, :archived)
us_park = create(:skatepark, :us_location)

# Multiple traits
us_draft = create(:skatepark, :draft, :us_location)
```

### Using Mocha for Mocking

```ruby
# Stub instance method
ApplicationController.any_instance.stubs(:http_basic_authenticate_or_request_with).returns(true)

# Expect method to be called
Rails.cache.expects(:delete).with('skateparks_popular')

# Stub class method
Rails.stubs(:env).returns(ActiveSupport::StringInquirer.new('production'))

# Mock object
rake_task = mock
rake_task.expects(:invoke)
Rake::Task.expects(:[]).with('sitemap:refresh').returns(rake_task)
```

### File Uploads in Tests

```ruby
# In test
def test_requires_cover_image
  skatepark = build(:skatepark)
  skatepark.cover_image = nil
  assert_equal false, skatepark.save
end

# Using fixture_file_upload (only in test context, not factories)
def test_with_single_image
  skatepark = build(:skatepark, images: [fixture_file_upload('sample_image1.jpg')])
  assert_equal false, skatepark.save # Requires at least 2 images
end
```

### Testing Validations

```ruby
def test_requires_field_to_be_present
  record = build(:model)
  record.field = nil
  assert_equal false, record.save
  assert_includes record.errors[:field], "can't be blank"
end

def test_validates_format
  record = build(:model, email: 'invalid')
  assert_equal false, record.save
  assert_includes record.errors[:email], "is invalid"
end
```

### Testing Callbacks

```ruby
def test_generates_slug_before_save
  skatepark = build(:skatepark, name_en: 'Test Park')
  assert_nil skatepark.slug

  skatepark.save
  assert_equal 'test-park', skatepark.slug
end

def test_updates_slug_when_name_changes
  skatepark = create(:skatepark, name_en: 'Old Name')
  assert_equal 'old-name', skatepark.slug

  skatepark.update(name_en: 'New Name')
  assert_equal 'new-name', skatepark.slug
end
```

---

## Troubleshooting

### "Factory not registered"

**Problem**: `KeyError: Factory not registered: "skatepark"`

**Solution**:

1. Check factory file exists: `test/factories/skateparks.rb`
2. Check factory is defined: `factory :skatepark do`
3. Restart test server if running in Docker

### "Cannot generate URL for attachment"

**Problem**: `Cannot generate URL for sample_image.jpg using Disk service`

**Solution**: Already configured in this project. If you see this:

1. Check `config/environments/test.rb` has ActiveStorage middleware
2. Check `test/test_helper.rb` sets `ActiveStorage::Current.url_options`

### "undefined method `fixture_file_upload'"

**Problem**: Using `fixture_file_upload` in factory file

**Solution**: Use `Rack::Test::UploadedFile` in factories:

```ruby
# In factory file
cover_image do
  Rack::Test::UploadedFile.new(
    Rails.root.join('test/fixtures/files/sample.jpg'),
    'image/jpeg'
  )
end

# In test file (where fixture_file_upload is available)
skatepark = build(:skatepark, images: [fixture_file_upload('sample.jpg')])
```

### Tests Failing with Database Pollution

**Problem**: Tests pass individually but fail when running full suite

**Solution**:

1. Check `use_transactional_tests = true` in test_helper.rb
2. Write tests that verify behavior, not exact state:

```ruby
# Bad (assumes empty database)
assert_equal [skatepark1], Skatepark.all.to_a

# Good (tests behavior)
assert_includes Skatepark.all, skatepark1
```

### Mocha Stubbing Not Working

**Problem**: `unexpected invocation` or stub doesn't work

**Solution**:

1. Check `require 'mocha/minitest'` in test_helper.rb
2. Use correct syntax:

```ruby
# Stub instance method on all instances
Model.any_instance.stubs(:method).returns(value)

# Stub class method
Model.stubs(:class_method).returns(value)

# Expect (will fail if not called)
Model.expects(:method).returns(value)
```

---

## Test Gems Used

### factory_bot_rails

**Purpose**: Create test data  
**Usage**: `create(:skatepark)`, `build(:skatepark)`  
**Why**: Easier than Rails fixtures for complex associations/traits

### faker

**Purpose**: Generate varied random data  
**Usage**: `Faker::Address.community`, `Faker::Lorem.paragraph`  
**Why**: Catches edge cases with varied data

### mocha

**Purpose**: Mocking and stubbing  
**Usage**: `Model.expects(:method)`, `stubs(:method).returns(value)`  
**Why**: More ergonomic than Minitest::Mock for complex cases

### rails-controller-testing

**Purpose**: Controller test helpers  
**Usage**: `assigns(:variable)` to access instance variables  
**Why**: Required for `assigns` helper (removed from Rails core)

### capybara

**Purpose**: System/integration tests  
**Usage**: `visit path`, `click_button`, `fill_in`  
**Why**: Required for browser-based testing

---

## Best Practices

### 1. Test One Thing Per Test

```ruby
# Bad - tests multiple things
def test_skatepark_creation
  skatepark = create(:skatepark)
  assert_not_nil skatepark.slug
  assert_equal 'published', skatepark.status
  assert_not_nil skatepark.cover_image
end

# Good - separate concerns
def test_generates_slug_on_creation
  skatepark = create(:skatepark)
  assert_not_nil skatepark.slug
end

def test_defaults_to_published_status
  skatepark = create(:skatepark)
  assert_equal 'published', skatepark.status
end
```

### 2. Use Descriptive Test Names

```ruby
# Bad
def test_skatepark
  # What does this test?
end

# Good
def test_requires_name_to_be_present
  # Clear what's being tested
end
```

### 3. Follow AAA Pattern (Arrange, Act, Assert)

```ruby
def test_filters_by_country
  # Arrange - set up test data
  greece = create(:skatepark, country_code: 'GR')
  usa = create(:skatepark, country_code: 'US')

  # Act - perform the action
  get skateparks_path(country_code: 'US')

  # Assert - verify the result
  assert_includes assigns(:skateparks), usa
  assert_not_includes assigns(:skateparks), greece
end
```

### 4. Keep Tests Fast

```ruby
# Use build when you don't need database
skatepark = build(:skatepark)  # Fast
skatepark.name = nil
assert_equal false, skatepark.save

# Only use create when needed
skatepark = create(:skatepark)  # Slower (database hit)
```

### 5. Avoid Test Interdependence

```ruby
# Bad - test order matters
def test_first
  @global_skatepark = create(:skatepark)
end

def test_second
  # Relies on @global_skatepark from previous test
  assert_not_nil @global_skatepark
end

# Good - each test is independent
def test_first
  skatepark = create(:skatepark)
  # Test uses local variable
end

def test_second
  skatepark = create(:skatepark)
  # Creates its own data
end
```

---

## Resources

- [Minitest Documentation](https://github.com/minitest/minitest)
- [Rails Testing Guide](https://guides.rubyonrails.org/testing.html)
- [FactoryBot Documentation](https://github.com/thoughtbot/factory_bot)
- [Mocha Documentation](https://github.com/freerange/mocha)
- [Capybara Documentation](https://github.com/teamcapybara/capybara)

---

## Quick Reference Card

### Test File Template

```ruby
require 'test_helper'

class MyModelTest < ActiveSupport::TestCase
  def setup
    # Runs before each test
    @record = create(:my_model)
  end

  def teardown
    # Runs after each test (rarely needed with transactions)
  end

  def test_some_behavior
    # Arrange
    @record.attribute = new_value

    # Act
    result = @record.save

    # Assert
    assert_equal true, result
  end
end
```

### Common Commands

```bash
# Run all tests
bin/rails test

# Run single file
bin/rails test test/models/skatepark_test.rb

# Run single test
bin/rails test test/models/skatepark_test.rb:42

# Run with coverage (in this project)
COVERAGE=true bin/rails test
```

### Assertion Cheat Sheet

```ruby
assert_equal a, b          # a == b
assert_not_equal a, b      # a != b
assert a                   # a is truthy
refute a                   # a is falsy
assert_nil a               # a.nil?
assert_empty a             # a.empty?
assert_includes coll, item # coll.include?(item)
assert_match /regex/, str  # str =~ /regex/
assert_raises(Error) { }   # Block raises Error
```

---

**Last Updated**: February 2026  
**Maintainer**: AI Assistant (via OpenCode)
