# Project Conventions

## Project-Specific Patterns

These conventions are specific to this codebase. Standard Ruby/Rails patterns are enforced by RuboCop and the specialized agents.

### Mobility i18n

```ruby
translates :name, type: :string
translates :description, backend: :action_text  # For ActionText
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
