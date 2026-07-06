# Video Suggestions (SK8-98)

Anonymous visitors can propose YouTube videos for a skatepark. Suggestions are stored as `pending` records and reviewed by admins before they appear on the public skatepark page.

---

## Overview

| Actor | Capability |
| ----- | ---------- |
| **Public (no login)** | Submit a YouTube URL from the skatepark show page |
| **Admin** | Review pending suggestions, activate on a skatepark, or reject |

Published skatepark pages only display **active** videos (`active_skatepark_videos`). Pending and rejected videos are hidden from the public UI.

---

## Data Model

`skatepark_videos` is the single table for both admin-managed videos and visitor suggestions.

```
skatepark_videos:
  skatepark_id          FK → skateparks (current / assigned skatepark)
  proposed_skatepark_id FK → skateparks (where the visitor submitted; immutable after create)
  youtube_url           string (max 255)
  youtube_video_id      string(11), not null (canonical 11-char YouTube ID)
  status                enum integer { pending: 0, active: 1, rejected: 2 }
  position              integer (meaningful for active videos only; pending/rejected use 0)
```

**Associations on `Skatepark`:**

| Association | Scope |
| ----------- | ----- |
| `skatepark_videos` | All videos |
| `active_skatepark_videos` | `status: active`, ordered by `position` |
| `proposed_skatepark_videos` | Videos originally proposed for this skatepark |

**Counter cache:** `skateparks.skatepark_videos_count` counts **active** videos only. Updated in `SkateparkVideo#sync_skatepark_active_videos_count` after create/update/destroy.

### Status lifecycle

```
                    ┌─────────────┐
  Visitor submits ─►│   pending   │
                    └──────┬──────┘
                           │
              ┌────────────┼────────────┐
              ▼            │            ▼
       ┌──────────┐        │     ┌──────────┐
       │  active  │        │     │ rejected │
       └──────────┘        │     └────┬─────┘
              │            │          │
              │            │          │ same URL can be resubmitted
              │            │          ▼
              │            │     (stale rejected row deleted on new create)
              ▼            │
     shown on public       │
     skatepark page        │
                           │
              Admin reject─┘
```

- **pending** — Awaiting moderation. Not shown publicly.
- **active** — Published on the assigned skatepark. Gets the next available `position` on activation.
- **rejected** — Dismissed by admin. Excluded from duplicate checks so the same video can be suggested again.

On create, a new pending suggestion sets:

- `skatepark` and `proposed_skatepark` to the page where it was submitted
- `position` to `0`
- `status` to `pending`

On admin **activate**, the record moves to `active`, `skatepark` may be reassigned, and `position` is allocated inside a row lock on the target skatepark.

---

## Routes

```
# Public
POST /skateparks/:skatepark_id/video_suggestion
     → Skateparks::VideoSuggestionsController#create

# Admin (requires admin session)
GET  /admin/video_suggestions
POST /admin/video_suggestions/:id/activate
POST /admin/video_suggestions/:id/reject
```

---

## Public flow

### Entry points

On the skatepark **show** page (`app/views/skateparks/show.html.erb`):

1. The **Videos** tab loads `active_skatepark_videos` only.
2. `_videos_grid.html.erb` renders active video thumbnails plus a **“Suggest a video”** CTA tile (`_video_suggestion_cta_tile.html.erb`).
3. The CTA opens a native `<dialog>` (`_video_suggestion_dialog.html.erb`) via Stimulus.

### Submission

`Skateparks::VideoSuggestionsController#create`:

1. Resolves the skatepark with `Skatepark.published.find` (draft/unpublished parks return 404).
2. Short-circuits on honeypot (`video_suggestion[website]` present) — returns success without creating a record.
3. Builds a `SkateparkVideo` with `status: :pending`, `position: 0`, and both skatepark FKs set to the current page.
4. Responds with **Turbo Stream** (replaces feedback partial) or HTML redirect.

### Frontend

| Piece | Role |
| ----- | ---- |
| `skatepark_video_suggestion_controller.js` | Opens/closes dialog (`showModal`), client-side URL validation, focus management |
| `lib/youtube_url.js` | Shared YouTube ID extraction (mirrors server logic) |
| Turbo Stream | Inline success/error feedback without full page reload |

Client validation runs on submit; server validation is authoritative.

### Abuse prevention

| Control | Setting |
| ------- | ------- |
| Per-IP rate limit | 5 requests / 15 minutes |
| Per-skatepark rate limit | 60 requests / hour |
| Honeypot field | Hidden `website` field; bots get a fake success |
| URL length | Max 255 characters |

Rate-limited responses return HTTP 429 (Turbo Stream) or redirect with alert (HTML). If the skatepark cannot be resolved during rate limiting, HTML clients redirect to the homepage.

---

## Admin flow

### Queue

`Admin::VideoSuggestionsController#index` lists `SkateparkVideo.pending_review`, newest first, with skatepark names eager-loaded for i18n.

Linked from **Admin dashboard** → “Review Video Suggestions”.

### Activate

1. Admin picks a target skatepark from a dropdown (defaults to current `skatepark_id`).
2. `POST activate` runs `activate_video_on!` inside `target_skatepark.with_lock`.
3. Sets `status: :active`, assigns `skatepark`, computes `position` via `SkateparkVideo.next_active_position_for`.
4. Flash notice differs when the video stays on the proposed skatepark vs. is reassigned.

### Reject

`POST reject` sets `status: :rejected`. The record stays tied to the original skatepark; it does not appear publicly.

### Direct admin video entry

When admins add videos through the skatepark edit form (`Admin::SkateparkVideoManagement#attach_new_videos`), new records are created with `status: :active` immediately so they publish without going through the moderation queue.

---

## Validation and uniqueness

### YouTube URL parsing

`SkateparkVideo.extract_video_id` accepts common URL shapes:

- `youtube.com/watch?v=…`
- `youtu.be/…`
- `youtube.com/shorts/…`, `/embed/…`, `/v/…`
- `m.youtube.com` and `youtube-nocookie.com/embed/…`

The extracted ID must match `/\A[A-Za-z0-9_-]{11}\z/`.

### Duplicate detection

Uniqueness is enforced on **`(skatepark_id, youtube_video_id)`** for `pending` and `active` statuses only (partial unique index). Rejected rows are ignored.

| Scenario | Error key |
| -------- | --------- |
| Same video already active on skatepark | `already_published` |
| Same video already pending on skatepark | `already_pending` |
| Race on unique index | `RecordNotUnique` rescued → appropriate error message |

Resubmitting after rejection is allowed. `before_create :remove_stale_rejected_duplicates` deletes any prior rejected row for the same skatepark + video ID.

`proposed_skatepark_id` cannot change after create (`proposed_skatepark_immutable` validation).

### Admin nested forms

`SkateparkVideoUrlUniqueness` on `Skatepark` rejects duplicate YouTube IDs among nested video attributes in a single form submission (excluding rejected records).

---

## Database

Migration: `db/migrate/20260704183000_add_video_suggestion_support_to_skatepark_videos.rb`

Notable changes:

- Added `status`, `youtube_video_id`, `proposed_skatepark_id`
- Backfilled existing rows to `active` with parsed video IDs
- Replaced global position unique index with a partial index on active videos only
- Partial unique index on `(skatepark_id, youtube_video_id)` where `status IN (0, 1)`
- Recounted `skatepark_videos_count` on all skateparks

---

## Internationalization

Copy lives under:

- `skateparks.video_suggestion.*` — public dialog, CTA, feedback
- `admin.video_suggestions.*` — moderation UI
- `activerecord.errors.models.skatepark_video.*` — validation messages

Keys exist in both `config/locales/en.yml` and `config/locales/el.yml`.

---

## Key files

| Area | Path |
| ---- | ---- |
| Public controller | `app/controllers/skateparks/video_suggestions_controller.rb` |
| Admin controller | `app/controllers/admin/video_suggestions_controller.rb` |
| Model | `app/models/skatepark_video.rb` |
| URL uniqueness concern | `app/models/concerns/skatepark_video_url_uniqueness.rb` |
| Admin video attach | `app/controllers/concerns/admin/skatepark_video_management.rb` |
| Stimulus | `app/javascript/controllers/skatepark_video_suggestion_controller.js` |
| YouTube helper | `app/javascript/lib/youtube_url.js` |
| Views | `app/views/skateparks/_video_suggestion_*.html.erb`, `app/views/admin/video_suggestions/index.html.erb` |

---

## Testing

```bash
docker compose -f docker-compose.test.yml --env-file ./.env.test run --rm skateparks-web-test bash -c \
  'bin/rails db:drop db:create db:migrate && DISABLE_SIMPLECOV=1 bin/rails test \
  test/controllers/skateparks/video_suggestions_controller_test.rb \
  test/controllers/admin/video_suggestions_controller_test.rb \
  test/models/skatepark_video_test.rb'
```

Coverage includes submission, validation, duplicates, resubmit-after-reject, honeypot, rate limits, concurrent `RecordNotUnique`, admin activate/reject/reassign, and invalid skatepark on activate.

See [minitest-implementation.md](minitest-implementation.md) for general test conventions.

---

## Operational notes

- **Homepage caches** — Activating or deactivating videos clears `Skatepark.homepage_latest_cache_key` and `homepage_popular_cache_key` when the active status changes.
- **Stale skatepark URLs** — `SkateparksController#set_skatepark` redirects to the homepage with `skateparks.not_found` when the slug/id does not match a published park (same behavior applies indirectly when suggestion targets are invalid).
- **Admin skatepark picker** — The activate dropdown lists all published skateparks. This works for the current dataset but may need a searchable picker if the directory grows significantly.
