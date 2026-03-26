---
name: rails-testing
description: Use when writing, debugging, or reviewing tests in this Rails app. Covers Docker-only test commands, Minitest conventions, assertions, stubs, authentication helpers, and Mobility examples.
---

# Rails Testing

This project uses **Minitest** (not RSpec). Tests **must** run via Docker.

## Test Commands

```bash
# All tests
docker compose -f docker-compose.test.yml exec skateparks-web-test bin/rails test

# With coverage
docker compose -f docker-compose.test.yml exec skateparks-web-test bash -c "COVERAGE=true bin/rails test"

# Single file
docker compose -f docker-compose.test.yml exec skateparks-web-test bin/rails test test/models/skatepark_test.rb

# By line number
docker compose -f docker-compose.test.yml exec skateparks-web-test bin/rails test test/models/skatepark_test.rb:42

# By method name
docker compose -f docker-compose.test.yml exec skateparks-web-test bin/rails test -n test_method_name
```

Container: `skateparks-web-test`. Start with `sh scripts.sh` -> "Start test server" if not running.

## Minitest Syntax (not RSpec)

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

## Key Assertions

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
ClassName.any_instance.stubs(:method).returns(value)
```

## Auth in Tests

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
