# Site Announcements

Admins can publish short bilingual news banners on the homepage. Announcements are separate from the **Go Skate Day** countdown banner and appear directly below it. Visitors can dismiss individual announcements; dismissal state is stored in browser `localStorage` and is independent of analytics consent.

---

## Overview

| Actor | Capability |
| ----- | ---------- |
| **Public (no login)** | See published, in-schedule announcements on the homepage; dismiss per announcement |
| **Admin** | Create, edit, reorder, schedule, publish, and delete announcements |

The homepage region renders only when at least one announcement matches `SiteAnnouncement.visible`. The component does not render an empty wrapper.

---

## Data Model

```
site_announcements:
  published     boolean, not null, default false
  position      integer, not null (display order; lower first)
  starts_at     datetime (optional schedule start)
  ends_at       datetime (optional schedule end)
  link_url      string (optional CTA; relative path or http(s) URL)
```

**Mobility translations** (via `string_translations`):

| Attribute | Required |
| --------- | -------- |
| `message` | Yes (EN + EL) |
| `link_label` | No (falls back to `home.site_announcements.read_more` when `link_url` is set) |

**Concerns:** `ReorderablePosition` — `position` must be a positive integer.

### Visibility lifecycle

```
                    ┌─────────────┐
  Admin creates ───►│    draft    │  published: false
                    └──────┬──────┘
                           │ publish
                           ▼
                    ┌─────────────┐
                    │  published  │
                    └──────┬──────┘
                           │
              ┌────────────┼────────────┐
              │            │            │
     starts_at in future   │     ends_at in past
              │            │            │
              ▼            ▼            ▼
         (hidden)    ┌──────────┐   (hidden)
                     │ visible  │
                     └──────────┘
                           │
              shown on homepage (unless dismissed)
```

**Scopes:**

| Scope | Filter |
| ----- | ------ |
| `ordered` | `position ASC, id ASC` |
| `published` | `published: true` |
| `currently_scheduled` | `starts_at` nil or ≤ now; `ends_at` nil or ≥ now |
| `visible` | `published.currently_scheduled.ordered` |

`#visible?(at = Time.zone.now)` mirrors the scope logic for a single record.

---

## Routes

```
# Admin (requires admin session)
GET    /admin/site_announcements
GET    /admin/site_announcements/new
POST   /admin/site_announcements
GET    /admin/site_announcements/:id/edit
PATCH  /admin/site_announcements/:id
DELETE /admin/site_announcements/:id
```

Linked from **Admin dashboard** → “Manage Site Announcements”.

---

## Public flow

### Placement

`app/views/home/index.html.erb` renders, in order:

1. `GoSkateDayCountdownComponent`
2. `HomepageSiteAnnouncementsComponent`
3. Main skatepark grid heading and content

The two banner features are intentionally separate — no shared model, controller, or component.

### Rendering

`HomepageSiteAnnouncementsComponent`:

- Defaults to `SiteAnnouncement.visible.to_a` when no `announcements:` argument is passed.
- `render?` returns false when the list is empty (no DOM output).
- Shows the localized `message` and an optional `LinkComponent` CTA.
- External URLs (`http://` / `https://`) open in a new tab; relative paths stay in the same tab.
- Each announcement is an `<article>` inside a `role="region"` wrapper labeled via `home.site_announcements.region_label`.
- No decorative icon in the message row — only text and optional link.

### Dismissal

| Piece | Role |
| ----- | ---- |
| `site_announcements_controller.js` | Filters dismissed items on connect; handles dismiss click, focus management |
| `lib/site_announcement_dismissals.js` | Read/write/clear `localStorage` keys |
| Inline `<script>` in component template | No-JS fallback: removes dismissed items before paint when JS is disabled |

**Storage key:** `skateparks.site_announcement.dismissed.{id}`

**Stored value:** `dismiss_token` — SHA256 hex digest of content fields:

```
message_en, message_el, link_label_en, link_label_el, link_url
```

| Scenario | Behavior |
| -------- | -------- |
| Stored token matches current token | Announcement hidden |
| Stored token differs (content changed) | Stale entry cleared; announcement shown again |
| Admin reorders only (`position` change) | Token unchanged; dismissal preserved |
| Admin edits message or link | Token changes; announcement reappears for users who dismissed the old version |

On dismiss with JavaScript enabled:

1. Token written to `localStorage`.
2. Article removed from DOM.
3. Focus moves to the next announcement’s dismiss button, or to `main h1` when the region becomes empty.
4. Empty region wrapper removed.

### Accessibility

- Region: `aria-label` from i18n.
- Article: `aria-labelledby` pointing at the message `<p>` id (`site-announcement-message-{id}`).
- Dismiss control: `IconButtonComponent` with `home.site_announcements.dismiss` as accessible name.
- Post-dismiss focus management for keyboard users.

### Privacy

Dismissal storage is **not** tied to analytics consent (PostHog). It uses the same browser `localStorage` mechanism as theme preference and is documented on the privacy page:

- `privacy.cookies_body` — explains theme + dismissed banners, not shared with analytics.
- `privacy.rights_body` — withdrawing analytics consent does not clear dismissed banners.

---

## Admin flow

### Index

`Admin::SiteAnnouncementsController#index` lists all announcements (`SiteAnnouncement.ordered`), including drafts and out-of-schedule records.

Columns: position (inline PATCH form), English message preview, published status, schedule summary, edit/delete actions.

Schedule column labels:

| State | Label key |
| ----- | --------- |
| No dates | `schedule_always` |
| Start + end | `schedule_range` |
| Start only | `schedule_from` |
| End only | `schedule_until` |

### Create / edit

Form fields: bilingual message and link label, `link_url`, `position`, `starts_at`, `ends_at`, `published` checkbox.

New records default `position` to `maximum(:position) + 1`.

### Destroy

Hard delete via `destroy!` with confirmation prompt on the index page.

---

## Validation

| Rule | Detail |
| ---- | ------ |
| `message_en`, `message_el` | Presence |
| `position` | Positive integer (`ReorderablePosition`) |
| `link_url` | Optional; must match `/…` or `http(s)://…` (`LINK_URL_PATTERN`) |
| `ends_at` | Must be after `starts_at` when both present |

---

## Database

Migration: `db/migrate/20260707190000_create_site_announcements.rb`

Mobility string translations are stored in the shared `string_translations` table (no extra columns on `site_announcements`).

---

## Internationalization

Copy lives under:

- `home.site_announcements.*` — public region label, read-more fallback, dismiss button
- `admin.site_announcements.*` — CRUD UI, schedule labels, flash notices
- `privacy.cookies_body`, `privacy.rights_body` — dismissal storage disclosure

Keys exist in both `config/locales/en.yml` and `config/locales/el.yml`.

---

## Key files

| Area | Path |
| ---- | ---- |
| Model | `app/models/site_announcement.rb` |
| Admin controller | `app/controllers/admin/site_announcements_controller.rb` |
| Homepage component | `app/components/homepage_site_announcements_component.rb`, `.html.erb` |
| Stimulus | `app/javascript/controllers/site_announcements_controller.js` |
| localStorage helper | `app/javascript/lib/site_announcement_dismissals.js` |
| Admin views | `app/views/admin/site_announcements/` |
| Homepage wiring | `app/views/home/index.html.erb` |
| Factory | `test/factories/site_announcements.rb` |

---

## Testing

```bash
docker compose -f docker-compose.test.yml --env-file ./.env.test run --rm skateparks-web-test bash -c \
  'bin/rails db:drop db:create db:migrate && DISABLE_SIMPLECOV=1 bin/rails test \
  test/models/site_announcement_test.rb \
  test/controllers/admin/site_announcements_controller_test.rb \
  test/components/homepage_site_announcements_component_test.rb \
  test/controllers/home_controller_test.rb'
```

Coverage includes:

- Model validations, scopes, `visible?`, `dismiss_token` stability on reorder vs content change
- Admin CRUD, authorization, validation errors
- Component rendering, locale, links, ARIA, dismiss controls, no-JS script presence
- Homepage integration (visible vs draft announcements)

See [minitest-implementation.md](minitest-implementation.md) for general test conventions.

---

## Operational notes

- **No server-side dismissal** — Dismiss state is client-only. Clearing browser storage or using another device shows announcements again.
- **Content edits resurrect dismissed banners** — By design: the `dismiss_token` fingerprint changes when copy or links change so users see updated news.
- **Homepage caching** — Unlike skatepark video activation, announcements are queried directly on each homepage render. If traffic grows, consider a fragment or query cache keyed on announcement `updated_at` max (tracked as SK8-115).
- **Go Skate Day** — Seasonal countdown logic remains in `GoSkateDayCountdownComponent`; do not merge scheduling or dismissal behavior into that component.
