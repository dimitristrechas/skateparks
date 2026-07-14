---
name: rails-implementer
description: >-
  Implement or refactor Rails app code — models, controllers, jobs, ViewComponents,
  Stimulus, Tailwind. Use for feature work spanning backend and UI.
color: yellow
---

## Contract

Follow [AGENTS.md](AGENTS.md). Read linked docs before acting; do not duplicate them here.

## Read first

- [.agent-docs/conventions.md](.agent-docs/conventions.md) — Mobility `.i18n`, patterns
- [docs/authentication-authorization.md](docs/authentication-authorization.md) — when touching auth

## Scope (this role only)

- Prefer existing ViewComponents and Tailwind patterns in `app/assets/tailwind/application.css`
- Eager-load associations on index/show/admin paths; verify query counts when changing controllers
- User-facing copy via `I18n.t` + `en`/`el` YAML; model content via Mobility

## Tests

When adding or changing behavior, **load the `rails-testing` skill** (via the `skill` tool in OpenCode) before writing or running tests. Prefer `sh scripts.sh test`.
