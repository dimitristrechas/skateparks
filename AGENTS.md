# AGENTS.md

Rails 8.1 skatepark directory app (Ruby 4.0.6, PostgreSQL 17, Hotwire, Tailwind 4.0).

**This file is the canonical source for project instructions and quality expectations.** Cursor rules under `.cursor/rules/` extend it for editor-specific behavior. Claude Code agents (`.claude/agents/`) and OpenCode (`opencode.json`) should mirror this contract, not replace it.

## Rules

- Do not commit unless explicitly instructed
- All code must pass linting (RuboCop, Herb, Prettier) and CI parity checks (`sh scripts.sh ci`) before push
- Prefer `sh scripts.sh` for development server, test server, lint, and formatter workflows whenever it supports the task. Fall back to direct `docker compose`, `bundle`, or `pnpm` commands only when `scripts.sh` does not cover the needed operation or automation requires a non-interactive command.
- **Before commit/push:** Run `sh scripts.sh test --fast` (or `sh scripts.sh test` for coverage) and `sh scripts.sh ci`. Do not rely on `sh scripts.sh lint` or pre-commit hooks alone — CI also runs `pnpm audit --audit-level moderate`, which is only included in `sh scripts.sh ci` and `sh scripts.sh security`.
- **Commit messages:** Use [Conventional Commits](https://www.conventionalcommits.org/) — see [.agent-docs/conventions.md](.agent-docs/conventions.md#commit-messages). Always include a `type` prefix and colon (e.g. `feat:`, `fix:`, `chore(agents):`). Do **not** use unprefixed subjects like `Add …` or `Refactor …`.

## Product quality (i18n, a11y, performance, UI)

- **User-facing copy:** No hardcoded English (or other locale strings) in views, components, mailers, or flash where `I18n.t` / YAML keys are appropriate. Use Mobility-translated model attributes for per-record content; use `config/locales/*.yml` for chrome, labels, ARIA strings, and shared UI. Add keys for **both** `en` and `el` when introducing new copy.
- **Mobility queries:** For `where` / `order` on translated columns, use `Model.i18n` (see [.agent-docs/conventions.md](.agent-docs/conventions.md)).
- **Accessibility:** Semantic HTML first; meaningful labels for interactive controls; keyboard support (Tab, Enter, Escape, arrows where applicable); visible focus; sufficient contrast. Decorative SVGs should use `aria-hidden="true"`.
- **Mobile / responsive:** Mobile-first layouts; respect touch targets (project components already use `min-h-8` / `min-w-8` patterns—follow them).
- **N+1 / queries:** For index, show, and admin lists, eager-load associations the view touches (`includes`, `preload`, `eager_load` as appropriate). After changing controllers or associations, verify query counts in tests or development (see [.agent-docs/commands.md](.agent-docs/commands.md)).
- **Visual consistency:** Prefer existing ViewComponents and patterns in `app/assets/tailwind/application.css` before ad hoc Tailwind. Match focus rings, spacing, and button styles used by `ButtonComponent`, `IconButtonComponent`, etc.

## Reference

- Operations & troubleshooting: [.agent-docs/operations.md](.agent-docs/operations.md)
- Commands: [.agent-docs/commands.md](.agent-docs/commands.md)
- Conventions: [.agent-docs/conventions.md](.agent-docs/conventions.md)
- Testing guide: [docs/minitest-implementation.md](docs/minitest-implementation.md)
- Authorization and Authentication guide: [docs/authentication-authorization.md](docs/authentication-authorization.md)
- Cross-tool AI and MCP: [.agent-docs/ai-tooling.md](.agent-docs/ai-tooling.md)
