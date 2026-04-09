# Project Conventions

## Project-Specific Patterns

These conventions are specific to this codebase. Standard Ruby/Rails patterns are enforced by RuboCop and the specialized agents.

### UI copy: YAML vs Mobility

- **Mobility** (`translates` on models): user-editable, per-record fields (e.g. skatepark name, rich description). Read/write via the model; locale follows `I18n.locale`.
- **`I18n.t` / `config/locales`:** Fixed chrome—navigation, buttons, form labels, flash, mailers, `aria-label` text, empty states. Every new key needs **English and Greek** entries in `en.yml` and `el.yml` unless explicitly locale-specific (e.g. SEO-only English).

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

### Accessibility and responsive UI

- Prefer semantic elements (`nav`, `main`, `button`, headings in order).
- Interactive controls need accessible names (`aria-label`, visible text, or `aria-labelledby`).
- Keyboard: focusable controls, Escape to close dialogs where applicable, no keyboard traps without escape.
- Mobile-first Tailwind; reuse `ButtonComponent`, `IconButtonComponent`, and existing focus/touch patterns.

### ActiveRecord loading and N+1

- In controllers, preload what the view or JSON response touches (`includes`, `preload`, `eager_load`).
- After adding associations or partials that iterate collections, check for N+1 (development: Bullet if enabled; tests: `assert_queries` where high-value—see testing guide).

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
