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

## Commit messages

Follow **Conventional Commits** for every commit. This matches the established repository history (`git log`).

### Format

```text
<type>[optional scope]: <subject>
```

- **`type`** (required): `feat`, `fix`, `chore`, `docs`, `refactor`, `test`, or `ci`
- **`scope`** (optional): area in parentheses — e.g. `(deps)`, `(ci)`, `(SK8-98)` for a Linear issue, `(agents)` for AI agent/skill/config changes
- **`subject`**: imperative mood, concise summary; **no trailing period**

### Examples from this repo

```text
feat: Add homepage site announcements with admin CRUD (#103)
fix: improve greek translations for suggestion feature
feat(SK8-98): Anonymous video suggestions and admin moderation (#101)
chore(deps): bump puma to 8.0.2 for PROXY protocol CVEs
fix(ci): install pnpm before setup-node cache step
agents: update and align structure
chore(agents): simplify subagents to two routers and two OpenCode skills
```

### Do not use

Unprefixed subjects (recent drift — not the project standard):

```text
Add counter bubbles to admin dashboard for pending videos.
Refactor scripts.sh with CLI subcommands and faster parallel lint checks.
Simplify AI subagents to two thin routers and two OpenCode skills.
```

### Type guide

| Type | When |
|------|------|
| `feat` | New user-facing behavior or capability |
| `fix` | Bug fix or correction |
| `chore` | Tooling, deps, config, maintenance (use scope when helpful: `chore(deps)`, `chore(agents)`) |
| `docs` | Documentation only |
| `refactor` | Code structure change without behavior change |
| `test` | Tests only |
| `ci` | CI/CD workflow changes |

For AI agent, skill, or `opencode.json` changes, use `chore(agents):` or `agents:` (both appear in history; prefer `chore(agents):` for consistency with scoped types).

Merged PRs may append `(#123)` to the subject when applicable.
