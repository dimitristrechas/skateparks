# SK8-70: Skatepark Videos Implementation Plan

## Summary

Add `SkateparkVideo` model with one-to-many association to `Skatepark`. Store YouTube URLs, display embedded videos on skatepark detail page with tabbed interface, show video count on homepage cards.

---

## Tasks

### 1. Database Migration

- Create `skatepark_videos` table:
  - `skatepark_id` (bigint, FK, indexed, not null)
  - `youtube_url` (string, not null)
  - `position` (integer, not null)
  - `timestamps`
- Add `skatepark_videos_count` counter cache column to `skateparks` table

### 2. SkateparkVideo Model

- `belongs_to :skatepark, counter_cache: true`
- `default_scope { order(position: :asc, created_at: :desc) }`
- Validations: presence for `skatepark`, `youtube_url`, `position`
- YouTube URL format validation (regex for youtube.com/youtu.be)
- Methods: `youtube_video_id`, `embed_url`

### 3. Skatepark Model Update

- Add `has_many :skatepark_videos, dependent: :destroy`

### 4. Admin Routes & Controller

- Nested routes: `resources :skateparks { resources :skatepark_videos, only: [:index, :create, :update, :destroy] }`
- `Admin::SkateparkVideosController` following `PopularSkateparksController` pattern
- HTTP basic auth

### 5. Admin Views

- Index page listing videos with position edit/delete
- Form to add new video (youtube_url, position)
- Link from skatepark show/edit page

### 6. Frontend - Tabbed Interface

- New Stimulus controller for tabs (`skatepark_tabs_controller.js`)
- Tabs: "Photos" | "Videos" on skatepark show page
- Photos tab: existing grid + lightbox
- Videos tab: responsive YouTube embeds grid (lazy loaded iframes)

### 7. Homepage Card Update

- Update `SkateparkCardComponent` to show `X photos • Y videos`
- Rely on counter cache for video count

### 8. I18n

- Add to en.yml/el.yml: `videos`, `photos_tab`, `videos_tab`, admin labels/notices

### 9. Testing

- Factory: `spec/factories/skatepark_videos.rb`
- Model spec: `spec/models/skatepark_video_spec.rb`
- Controller spec: `spec/controllers/admin/skatepark_videos_controller_spec.rb`
- Update `skatepark_card_component_spec.rb` for video count

---

## Decisions Made

| Question | Decision |
|----------|----------|
| Separate model needed? | Yes - follows `PopularSkatepark` pattern, allows per-video ordering/validation |
| Admin UI location | Nested under skateparks (`/admin/skateparks/:id/skatepark_videos`) |
| Frontend display | Tabbed interface (Photos \| Videos) |
| Video count format | `X photos • Y videos` (with dot separator) |
| Counter cache | Yes - `skatepark_videos_count` on skateparks table |
| Max videos | No limit |

---

## Related

- Linear Issue: [SK8-70](https://linear.app/dimitris-trechas-workspace/issue/SK8-70/skatepark-videos)
- Git Branch: `dimitristrechas/sk8-70-skatepark-videos`
