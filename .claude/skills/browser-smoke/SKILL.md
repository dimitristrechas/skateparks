---
name: browser-smoke
description: >-
  Use to sanity-check the running app in a real browser after UI, view, controller, route, locale,
  or Stimulus changes, before opening a PR, or when asked to "check it in the browser". Drives the
  dev server with agent-browser for public and admin routes (en + el), and covers Capybara system tests.
compatibility: opencode
---

# Browser smoke checks

Canonical project instructions live in **`AGENTS.md`**. Commands: **`.agent-docs/commands.md`**.

Two layers, same browser engine (Chromium):

| Layer                     | Command                       | Runs against                            | Use for                                      |
| ------------------------- | ----------------------------- | --------------------------------------- | -------------------------------------------- |
| agent-browser smoke       | `sh scripts.sh browser smoke` | Dev server (`localhost:3002`, dev DB)   | Fast sanity check of real data, both locales |
| agent-browser exploration | `agent-browser --session …`   | Dev server                              | Inspecting a specific page/flow you changed  |
| Capybara system tests     | `sh scripts.sh test --system` | Disposable test DB + Chromium container | Regressions worth keeping in CI              |

Use agent-browser for every tool (Claude Code, Cursor, OpenCode, Codex). Do not substitute editor-specific
browsers or MCP browser servers, so results are comparable across agents.

## Prerequisites

1. `agent-browser` on the host (`brew install agent-browser && agent-browser install`). Run `agent-browser skills get core` once if you need the command reference.
2. Dev stack up: `sh scripts.sh dev up` (app on `http://localhost:3002`).
3. `.env` has `ADMIN_EMAIL` / `ADMIN_PASSWORD`. The admin user exists only if `sh scripts.sh dev seed` ran while no admin existed.

**Never read, print, or pass admin credentials yourself.** `sh scripts.sh browser login` reads them from `.env` and saves the signed-in state to `tmp/agent-browser/admin-state.json` (gitignored).

## Workflow

```bash
sh scripts.sh browser smoke                 # public + admin routes, en + el
sh scripts.sh browser smoke --public        # or --admin
sh scripts.sh browser smoke --mobile        # 390×844 viewport + horizontal-overflow check
sh scripts.sh browser smoke --screenshots   # PNGs in tmp/agent-browser/screenshots/
sh scripts.sh browser login                 # re-auth admin session (smoke does this automatically)
sh scripts.sh browser close                 # close both browser sessions when done
```

Each page is checked for: HTTP 200, no redirect to sign-in, no JS page errors, no `.translation_missing`
spans, and (with `--mobile`) no horizontal overflow. The route lists live in `scripts/browser.sh`
(`BROWSER_PUBLIC_PATHS`, `BROWSER_ADMIN_PATHS`); add new top-level routes there.

When smoke fails, find the cause in `sh scripts.sh dev logs` (500s, `Translation missing` errors).

## Exploring a changed page

Reuse the smoke sessions so admin stays signed in:

```bash
agent-browser --session skateparks-admin open "http://localhost:3002/admin/skateparks?locale=el"
agent-browser --session skateparks-admin snapshot -i -c   # accessibility tree with @refs
agent-browser --session skateparks-admin click @e12
agent-browser --session skateparks-admin errors           # JS errors
agent-browser --session skateparks-admin a11y             # axe-core audit
agent-browser --session skateparks-public set viewport 390 844
agent-browser --session skateparks-public screenshot tmp/agent-browser/screenshots/check.png
```

- Public pages: session `skateparks-public`. Admin pages: session `skateparks-admin`.
- Greek: append `?locale=el`; English is the default (no param).
- Review against `AGENTS.md` product quality: translated copy in both locales, labelled controls, keyboard
  reachability, visible focus, mobile layout.
- Do not submit destructive admin actions (ban, reject, delete) against dev data unless asked.

## Capybara system tests

- Base class: `test/application_system_test_case.rb` (Selenium + headless Chrome; `sign_in_as(user)`,
  `localized_path(path, locale)`).
- `sh scripts.sh test --system [path]` starts the `skateparks-chrome` container (compose profile `test`)
  and runs with `SELENIUM_REMOTE_URL`, one worker, no coverage. CI runs `bin/rails test test/system` with the
  runner's local Chrome.
- `bin/rails test` and `sh scripts.sh test` do **not** include system tests.
- Failure screenshots: `tmp/screenshots/`.
- Keep system tests few and journey-level (sign-in, admin access, critical public pages). Prefer
  controller/component tests for everything else (see `rails-testing` skill).
- Use `I18n.t` for labels in finders; wait with Capybara matchers (`assert_current_path`,
  `assert_selector`), never `sleep`.
