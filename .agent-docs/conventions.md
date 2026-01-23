# Project Conventions

## Project-Specific Patterns

These conventions are specific to this codebase. Standard Ruby/Rails patterns are enforced by RuboCop and the specialized agents.

### Mobility i18n

```ruby
translates :name, type: :string
translates :description, backend: :action_text  # For ActionText
```

**Querying translated attributes:** Use `.i18n` scope for where/order on translated fields:

```ruby
# Wrong - queries the raw column, not translations
Skatepark.order(:name)
Skatepark.where(name: "foo")

# Correct - uses Mobility's locale-aware queries
Skatepark.i18n.order(:name)
Skatepark.i18n.where(name: "foo")
```

### Cache Invalidation

Add `after_save` and `after_destroy` callbacks for cache invalidation.

### Enums

```ruby
enum :status, { draft: 0, published: 1 }
```

### Strong Params (Rails 8)

```ruby
params.expect(model: [:field])  # Not params.require().permit()
```

### Stimulus Handlers

```javascript
handleClick = (event) => {}; // Arrow functions for event handlers
```
