---
name: rails-testing
description: >-
  Use when writing, debugging, or reviewing Minitest tests in this Rails app.
  Covers Docker-only test commands, assertions, Mocha stubs, auth helpers, and Mobility patterns.
compatibility: opencode
---

# Rails Testing

Canonical project instructions live in **`AGENTS.md`**. Full guide: **`docs/minitest-implementation.md`**. Conventions: **`.agent-docs/conventions.md`**.

This project uses **Minitest** (not RSpec). Tests **must** run via Docker.

## When to use me

Use when writing new tests, debugging failures, adding coverage, setting up factories, mocking with Mocha, or testing ViewComponents and controllers.

## What I do

- Docker-only test commands via `sh scripts.sh test`
- Minitest syntax, Mocha stubs, auth helpers, Mobility patterns
- Project-specific areas to test and a debugging checklist

## Test commands

Prefer `scripts.sh`:

```bash
sh scripts.sh test                           # All tests with coverage
sh scripts.sh test --fast                    # All tests without coverage
sh scripts.sh test test/models/foo_test.rb   # Single file or line
```

Container: `skateparks-web-test`. Start with `sh scripts.sh test-server up` if not running.

Direct Docker fallback:

```bash
docker compose -f docker-compose.test.yml exec skateparks-web-test bin/rails test test/models/skatepark_test.rb
docker compose -f docker-compose.test.yml exec skateparks-web-test bin/rails test test/models/skatepark_test.rb:42
docker compose -f docker-compose.test.yml exec skateparks-web-test bin/rails test -n test_method_name
```

## Minitest syntax (not RSpec)

```ruby
class SkateparkTest < ActiveSupport::TestCase
  def setup
    @skatepark = create(:skatepark)
  end

  def test_requires_name
    @skatepark.name = nil
    assert_not @skatepark.valid?
  end
end
```

| Test type      | Base class                        |
| -------------- | --------------------------------- |
| Models         | `ActiveSupport::TestCase`         |
| Controllers    | `ActionDispatch::IntegrationTest` |
| ViewComponents | `ViewComponent::TestCase`         |
| Workers        | `ActiveSupport::TestCase`         |
| System         | `ApplicationSystemTestCase`       |

## Key assertions

```ruby
assert expr / assert_not expr
assert_equal expected, actual       # expected FIRST
assert_nil / assert_not_nil
assert_includes collection, item
assert_raises(Error) { block }
assert_difference('Model.count', 1) { create(:model) }
assert_response :success / :redirect / :forbidden
assert_redirected_to path
```

## Mocking: Mocha (not RSpec mocks)

```ruby
object.stubs(:method).returns(value)
object.expects(:method).once
Cloudinary::Uploader.stubs(:upload).returns({ 'url' => 'https://...' })
ClassName.any_instance.stubs(:method).returns(value)
```

## Auth in tests

```ruby
login_as(create(:user))           # regular user
login_as(create(:user, :admin))   # admin
# No call = unauthenticated request
```

## Mobility i18n

```ruby
I18n.with_locale(:el) { assert_equal 'Σκέιτπαρκ', @skatepark.name }
Skatepark.i18n.where(name: 'x')   # use .i18n scope for translated queries
```

Multilingual factories: set `name_en` and `name_el` separately.

## What to test (project-specific)

- Mobility translations (`name_en`/`name_el` per locale)
- Status enum transitions (draft → published)
- Cloudinary uploads — stub `Cloudinary::Uploader.upload`
- Kaminari pagination — test page scoping
- ActionText rich text content
- Country/state filtering scopes
- Authentication and authorization (admin vs regular user)
- Rate limiting on login/password endpoints
- Cache invalidation (`after_save`/`after_destroy` callbacks)
- Slug generation and uniqueness

## When debugging failures

1. Check if test container is running: `docker ps | grep skateparks-web-test`
2. Run a single test with full output: append `2>&1` to see all logs
3. Check transactional test isolation — tests use `use_transactional_tests = true`
4. Verify factory associations are valid before testing model logic
5. Check Mobility locale context — missing locale can cause nil translations

## Code style

- Method names: `test_description_of_behavior` (snake_case, starts with `test_`)
- No magic strings — use factory sequences or named constants
- One logical assertion cluster per test method
- Follow existing patterns in `test/`
