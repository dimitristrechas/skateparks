# SEO Guide

How skateparks.gr implements search-engine metadata, structured data, internationalization, crawling, and sitemaps.

---

## Overview

| Layer | Responsibility |
| ----- | -------------- |
| **Controllers** | Set per-page `@title`, `@meta_description`, and `@meta_image` instance variables |
| **Model (`Skatepark`)** | Store optional per-locale SEO overrides; compute fallbacks (`seo_title`, `seo_description`) |
| **Layout + partials** | Render `<title>`, meta description, robots, Open Graph, Twitter Cards, canonical, hreflang |
| **`SeoHelper`** | Canonical/hreflang URL generation and social-meta fallbacks |
| **`SchemaHelper`** | JSON-LD structured data (Organization, WebSite, page-specific schemas) |
| **Sitemap + robots** | Crawl discovery and admin exclusion |
| **i18n (`config/locales`)** | Site-wide default copy and static-page metadata |

All public HTML pages share `app/views/layouts/application.html.erb`. SEO output is driven by controller assigns with locale-aware fallbacks.

---

## Architecture

Data flows from controllers and the `Skatepark` model into layout partials and helpers:

1. **Controllers** set `@title`, `@meta_description`, and optionally `@meta_image` (or leave them unset for site defaults).
2. **`Skatepark#show`** derives `@title` / `@meta_description` from `seo_title` / `seo_description` instead of setting them directly in the view.
3. **Partials** (`_title.html.erb`, `_description.html.erb`) render the HTML head, falling back to `application.*` locale keys.
4. **`SeoHelper`** builds canonical/hreflang URLs and social-meta fallbacks from the same controller assigns.
5. **`SchemaHelper`** emits JSON-LD using those assigns (or skatepark-specific methods on show pages).

Homepage and skateparks index skip step 1 and use site-wide defaults from `config/locales`.

### Fallback chain

Every public page resolves metadata in this order:

1. **Controller assigns** — `@title`, `@meta_description`, `@meta_image` when set.
2. **Partials** — `_title.html.erb` and `_description.html.erb` fall back to `t('application.title')` and `t('application.meta_description')`.
3. **Social helpers** — `social_title`, `social_description`, and `social_image` in `SeoHelper` read the same controller assigns and fall back again for OG/Twitter tags.
4. **JSON-LD** — `SchemaHelper` uses the same values (or skatepark-specific methods on show pages).

---

## Page-by-page metadata

| Page | Controller action | `@title` | `@meta_description` | `@meta_image` | JSON-LD schema |
| ---- | ----------------- | -------- | ------------------- | ------------- | -------------- |
| Homepage | `home#index` | *(default)* | *(default)* | `logo-og.png` | `WebPage` |
| Skateparks index | `skateparks#index` | *(default)* | *(default)* | `logo-og.png` | `CollectionPage` + `ItemList` |
| Skatepark show | `skateparks#show` | `skatepark.seo_title` | `skatepark.seo_description` | Cover image URL | `SportsActivityLocation` |
| About | `home#about` | `t('about.title')` | `t('about_details')` | `logo-og.png` | `WebPage` |
| Contact | `home#contact` | `t('contact')` | `t('contact_details')` | `logo-og.png` | `WebPage` |
| Privacy | `home#privacy` | `t('privacy.title')` | `t('privacy.meta_description')` | `logo-og.png` | `WebPage` |
| Admin (`/admin/*`) | various | *(default)* | *(default)* | `logo-og.png` | `WebPage` |

Site-wide defaults live in `config/locales/en.yml` and `config/locales/el.yml` under `application.title` and `application.meta_description`.

---

## Skatepark SEO (model layer)

### Database fields

`Skatepark` uses [Mobility](https://github.com/shioyama/mobility) for per-locale string translations:

```ruby
translates :meta_title, type: :string
translates :meta_description, type: :string
```

Locale accessors: `meta_title_en`, `meta_title_el`, `meta_description_en`, `meta_description_el`.

### Computed methods

```ruby
def seo_title
  meta_title.presence || "#{name} | Skateparks.gr"
end

def seo_description
  meta_description.presence || truncated_plain_description
end

def truncated_plain_description(max_length: 160)
  text = description.to_plain_text.squish
  return text if text.length <= max_length

  text.truncate(max_length, separator: /\s/, omission: '…')
end
```

| Method | When override is blank | When override is set |
| ------ | ---------------------- | -------------------- |
| `seo_title` | `"#{name} \| Skateparks.gr"` | Uses `meta_title` verbatim |
| `seo_description` | Truncated plain-text body (max 160 chars, word boundary) | Uses `meta_description` verbatim (no truncation) |

Both methods resolve in the **current `I18n.locale`** via Mobility.

### URL slugs

- `to_param` returns `"#{id}-#{slug}"` (e.g. `36-royal-square-skatepark-29`).
- Slug is generated from `name_en.parameterize` — locale-neutral path; Greek uses `?locale=el`.
- Stale slugs redirect to the homepage with a flash message (not a soft 404).
- Only **published** skateparks are reachable on the public show action.

**File:** `app/models/skatepark.rb`

---

## Controller assigns

### Skatepark show

```ruby
# app/controllers/skateparks_controller.rb
def show
  @title = @skatepark.seo_title
  @meta_description = @skatepark.seo_description
  @meta_image = url_for(@skatepark.cover_image)
  # ...
end
```

### Static pages

```ruby
# app/controllers/home_controller.rb
def about
  @title = t('about.title')
  @meta_description = t('about_details')
end
```

Contact and privacy follow the same pattern with their respective locale keys.

---

## Layout and HTML head

**File:** `app/views/layouts/application.html.erb`

### Document language

```erb
<html lang="<%= I18n.locale %>">
```

### Title and description partials

| Partial | Output | Fallback |
| ------- | ------ | -------- |
| `app/views/application/_title.html.erb` | `<title>` | `t('application.title')` |
| `app/views/application/_description.html.erb` | `<meta name="description">` | `t('application.meta_description')` |

The title tag uses `data-turbo-permanent` so Turbo Drive navigations keep a stable head title element.

### Robots meta tag

Default for all dynamic pages:

```html
<meta name="robots" content="index, follow">
```

Override per view with a content block:

```erb
<% content_for :meta_robot do %>
  <meta name="robots" content="noindex, nofollow">
<% end %>
```

The layout yields `:meta_robot` when present. No views use this hook yet — it is the extension point for future `noindex` pages (e.g. account settings).

Static error pages in `public/` (`400.html`, `404.html`, `422.html`, `500.html`, `406-unsupported-browser.html`) hard-code `noindex, nofollow`.

### Open Graph and Twitter Cards

Rendered on every page (including admin):

| Tag | Source |
| --- | ------ |
| `og:title` / `twitter:title` | `social_title` |
| `og:description` / `twitter:description` | `social_description` |
| `og:image` / `twitter:image` | `social_image` |
| `og:site_name` | Hard-coded `Skateparks.gr` |
| `og:type` | Hard-coded `website` |
| `twitter:card` | `summary_large_image` |
| `og:url` | `canonical_url` on public pages; `url_for(protocol: 'https')` on admin |

Default social image: `app/assets/images/logo-og.png`.

### Canonical and hreflang

Rendered only on **public** pages (`public_seo_page?` returns false for `/admin/*`):

```erb
<link rel="canonical" href="...">
<link rel="alternate" hreflang="en" href="...">
<link rel="alternate" hreflang="el" href="...">
<link rel="alternate" hreflang="x-default" href="...">
```

### JSON-LD

```erb
<%= json_ld_schema(
  skatepark: defined?(@skatepark) ? @skatepark : nil,
  skateparks: defined?(@skateparks) ? @skateparks : nil,
  title: @title,
  meta_description: @meta_description,
  meta_image: @meta_image,
) %>
```

---

## SeoHelper

**File:** `app/helpers/seo_helper.rb`

| Method / constant | Purpose |
| ----------------- | ------- |
| `LOCALE_ALTERNATE_PARAMS` | `%i[country_code state page]` — filter/pagination params preserved in alternate URLs |
| `public_seo_page?` | `true` unless `request.path` starts with `/admin` |
| `seo_page_url(locale:)` | Full HTTPS URL for current path + locale + filtered query params |
| `canonical_url` | `seo_page_url(locale: I18n.locale)` |
| `hreflang_link_tags` | Alternate links for `en`, `el`, and `x-default` |
| `social_title` | `view_assigns['title']` → `t('application.title')` |
| `social_description` | `view_assigns['meta_description']` → `t('application.meta_description')` |
| `social_image` | `view_assigns['meta_image']` → `image_url('logo-og.png')` |

### HTTPS in URLs

`seo_page_url` always passes `protocol: 'https'`, matching production `force_ssl` behavior. Canonical, hreflang, and `og:url` on public pages all use HTTPS absolute URLs.

### Locale URL model

- Locale is a **query parameter** (`?locale=el`) for non-default locales; the default locale (`en`) uses clean URLs without a locale param.
- `ApplicationController#default_url_options` adds `locale: I18n.locale` only when the current locale is not the default.
- Explicit `?locale=en` requests receive a **301 redirect** to the clean URL, consolidating duplicate English URLs for crawlers.
- `x-default` hreflang points at the default-locale URL (no `locale` param).
- Language switcher (`app/views/home/_locale_selector.html.erb`) and hreflang links preserve `country_code`, `state`, and `page` when present — keeping filtered index URLs consistent across locales.

---

## SchemaHelper (JSON-LD)

**File:** `app/helpers/schema_helper.rb`

`json_ld_schema` emits a single `<script type="application/ld+json">` containing an array of Schema.org objects.

### Always included

| Schema | `@type` | Key fields |
| ------ | ------- | ---------- |
| Organization | `Organization` | `name: skateparks.gr`, `url`, `description`, `sameAs: []` |
| WebSite | `WebSite` | `inLanguage: [el, en]`, `SearchAction` targeting the skateparks index |

### Page-specific (by `controller_name#action_name`)

| Route | Additional schema | `@type` | Notes |
| ----- | ----------------- | ------- | ----- |
| `skateparks#show` | `skatepark_schema` | `SportsActivityLocation` | Uses `seo_title`, `seo_description`, geo, address, up to 5 images |
| `skateparks#index` | `collection_page_schema` | `CollectionPage` + `ItemList` | `numberOfItems` from paginated `total_count` or array size |
| Everything else | `webpage_schema` | `WebPage` | Uses passed title/description/image or I18n/asset fallbacks |

### SearchAction URL template

`website_schema` includes a sitelinks search box target:

```text
https://www.skateparks.gr/skateparks?search={search_term_string}
```

When the skateparks URL already contains a query string (e.g. `?locale=en`), the helper uses `&` as the joiner to avoid double `?` characters.

### Skatepark structured data fields

| Field | Source |
| ----- | ------ |
| `name` | `skatepark.seo_title` (aligned with `<title>` and OG) |
| `description` | `skatepark.seo_description` |
| `url` / `@id` | `skatepark_url(protocol: 'https')` |
| `image` | Cover image + gallery images (max 5) |
| `geo` | `GeoCoordinates` when lat/lng present |
| `address` | `PostalAddress` with `addressCountry` and optional `addressRegion` |

---

## Admin SEO editing

Admins can override per-skatepark SEO metadata in the skatepark edit form.

**Form:** `app/views/admin/skateparks/_form.html.erb` (SEO section)

| Field | Locale | Label key |
| ----- | ------ | --------- |
| `meta_title_el` | Greek | `skatepark.meta_title_el` |
| `meta_description_el` | Greek | `skatepark.meta_description_el` |
| `meta_title_en` | English | `skatepark.meta_title_en` |
| `meta_description_en` | English | `skatepark.meta_description_en` |

The form displays guidance from `admin.skateparks.form.seo_hint`:

> Optional. Leave blank to use the skatepark name and a shortened page description. Recommended: title up to 60 characters, description up to 160 characters.

SEO field groups use `col-span-2 sm:col-span-1` so they stack full-width on narrow screens.

**Strong params:** `app/controllers/admin/skateparks_controller.rb` permits `meta_title_el`, `meta_title_en`, `meta_description_el`, `meta_description_en`.

There is no model validation enforcing the 60/160 character guidance — admins can paste longer overrides.

---

## Internationalization keys

### Site-wide defaults

| Key | Used for |
| --- | -------- |
| `application.title` | Default `<title>`, `social_title`, `webpage_schema.name` |
| `application.meta_description` | Default meta description, schema descriptions, `social_description` |

### Static page metadata

| Key | Page |
| --- | ---- |
| `about.title` / `about_details` | About |
| `contact` / `contact_details` | Contact |
| `privacy.title` / `privacy.meta_description` | Privacy |

All keys exist in both `config/locales/en.yml` and `config/locales/el.yml`.

### Admin form labels

| Key | Purpose |
| --- | ------- |
| `admin.skateparks.form.seo_heading` | Section heading ("SEO") |
| `admin.skateparks.form.seo_hint` | Helper text under heading |
| `skatepark.meta_title_el/en` | Field labels |
| `skatepark.meta_description_el/en` | Field labels |

---

## Crawling and discovery

### robots.txt

**File:** `public/robots.txt`

```text
User-agent: *
Disallow: /admin/
Sitemap: https://www.skateparks.gr/sitemap.xml.gz
```

Admin paths are blocked from crawling. Public admin pages still emit `index, follow` in the robots meta tag, but crawlers respect `robots.txt`.

### Sitemap

**Config:** `config/sitemap.rb` (with `lib/sitemap_locale_helper.rb`)

```ruby
SitemapGenerator::Sitemap.default_host = 'https://www.skateparks.gr'

SitemapGenerator::Sitemap.create do
  extend SitemapLocaleHelper

  add_localized '/'
  add_localized '/skateparks'
  add_localized '/about'
  add_localized '/contact'
  add_localized '/privacy'

  Skatepark.published.find_each do |skatepark|
    add_localized skatepark_path(skatepark), lastmod: skatepark.updated_at
  end
end
```

Each entry includes `xhtml:link` alternates for `en`, `el`, and `x-default`. English URLs omit the `locale` query param; Greek URLs use `?locale=el`.

| Included | Not included |
| -------- | ------------ |
| `/`, `/skateparks`, `/about`, `/contact`, `/privacy` | Filtered/paginated index URLs |
| Published skatepark show pages (with hreflang alternates) | Admin pages |
| | `?locale=en` variants (canonical English URLs have no locale param) |

### Sitemap generation schedule

| Trigger | Mechanism |
| ------- | --------- |
| Deploy | `bin/release` runs `bundle exec rake sitemap:refresh` |
| Weekly | `SitemapWorker` via Sidekiq (`config/schedule.yml` — Sundays 03:00) |
| Output | `public/sitemap.xml.gz` |

**Worker:** `app/workers/sitemap_worker.rb` invokes `sitemap:refresh:no_ping`.

### Google Search Console

Site verification file: `public/google21aa4f7f015004e1.html`.

---

## HTTPS and URL redirects

### Production SSL

**File:** `config/environments/production.rb`

```ruby
config.assume_ssl = true
config.force_ssl = true
```

SEO helpers and schema URLs hard-code `protocol: 'https'` independently of the request scheme.

### Permanent redirects for renamed skateparks

**File:** `config/routes.rb` (production only)

```ruby
get '/skateparks/16-xanthi' => redirect('/skateparks/21-xanthi', status: 301)
get '/skateparks/32-elefsina' => redirect('/skateparks/35-elefsina', status: 301)
```

Add new 301 redirects here when consolidating or renaming skatepark URLs.

---

## Admin vs public behavior

| Feature | Public pages | Admin (`/admin/*`) |
| ------- | ------------ | ------------------ |
| `<title>` / meta description | Per-page or site defaults | Site defaults only |
| Canonical URL | Yes | No |
| Hreflang alternates | Yes | No |
| Open Graph / Twitter | Yes | Yes (generic defaults) |
| JSON-LD | Context-aware | Usually `WebPage` |
| `robots.txt` | Allowed | `Disallow: /admin/` |
| Umami analytics | Production only | Excluded |
| Editable SEO fields | N/A | Admin skatepark form |

---

## How to change SEO copy

### Per-skatepark overrides (admin)

1. Log in as admin → edit a skatepark.
2. Scroll to the **SEO** section.
3. Fill in optional title/description fields for Greek and/or English.
4. Save. Public show pages use the override for the matching locale immediately.

### Site-wide defaults

Edit `application.title` and `application.meta_description` in **both** `config/locales/en.yml` and `config/locales/el.yml`.

### Static page metadata

Edit the relevant keys in both locale files (see [Internationalization keys](#internationalization-keys)).

### Add a new public page with custom metadata

1. Set `@title` and `@meta_description` in the controller action.
2. Optionally set `@meta_image` for a custom social preview image.
3. Add locale keys in `en.yml` and `el.yml` — no hardcoded copy in views.
4. `SchemaHelper` will emit a `WebPage` schema automatically unless you add a new route-specific case.

### Add `noindex` to a page

```erb
<% content_for :meta_robot do %>
  <meta name="robots" content="noindex, nofollow">
<% end %>
```

---

## Testing

SEO behavior is covered by Minitest across models, controllers, and helpers.

| Area | File | What's tested |
| ---- | ---- | ------------- |
| `seo_title` / `seo_description` fallbacks | `test/models/skatepark_test.rb` | Name suffix, overrides, truncation |
| Show page meta assigns | `test/controllers/skateparks_controller_test.rb` | Default and custom EN/EL overrides |
| Canonical + hreflang in HTML | `test/controllers/skateparks_controller_test.rb` | HTTPS canonical, all hreflang values |
| Default-locale redirect | `test/controllers/application_controller_test.rb` | 301 from `?locale=en` to clean URL |
| Canonical/hreflang URL helpers | `test/helpers/seo_helper_test.rb` | Default-locale omission, filter params |
| Sitemap locale alternates | `test/lib/sitemap_locale_helper_test.rb` | `en`, `el`, `x-default` hreflang entries |
| Twitter Cards in HTML | `test/controllers/skateparks_controller_test.rb` | Card type and title |
| Static page assigns | `test/controllers/home_controller_test.rb` | About, contact, privacy |
| Admin SEO form + persist | `test/controllers/admin/skateparks_controller_test.rb` | Field rendering, PATCH persistence |
| Social meta fallbacks | `test/helpers/seo_helper_test.rb` | `social_title`, `social_description`, `social_image` |
| Organization / WebSite schema | `test/helpers/schema_helper_test.rb` | Structure, SearchAction URL, locale-aware description |
| Sitemap worker | `test/jobs/sitemap_worker_test.rb` | Rake task invocation |

### Gaps in test coverage

Not currently tested (worth adding if SEO regressions are a concern):

- Open Graph tags in rendered HTML
- JSON-LD content in rendered HTML
- `canonical_url` / `hreflang_link_tags` unit tests (partial — see `test/helpers/seo_helper_test.rb`)
- `skatepark_schema` and `collection_page_schema` builders
- Sitemap XML output contents (helper covered in `test/lib/sitemap_locale_helper_test.rb`)
- Homepage and skateparks index default metadata

Run SEO-related tests:

```bash
sh scripts.sh test test/models/skatepark_test.rb
sh scripts.sh test test/controllers/skateparks_controller_test.rb
sh scripts.sh test test/helpers/seo_helper_test.rb
sh scripts.sh test test/helpers/schema_helper_test.rb
```

---

## Known limitations and future improvements

1. **Homepage and skateparks index** use only site-wide defaults — no controller-level `@title` / `@meta_description` overrides.
2. **Sitemap** omits filtered/paginated index URLs.
3. **`contact_details`** is a minimal meta description ("Contact" / "Στοιχεία επικοινωνίας") — weak for SERP snippets.
4. **Custom `meta_description`** overrides are not truncated or validated — long admin input can produce long SERP snippets.
5. **`organization_schema` `sameAs`** is an empty array placeholder for future social profile URLs.
6. **Filter query params** (`country_code`, `state`, `page`) are preserved in canonical/hreflang URLs on any page where they appear in the request — including show pages if bookmarked with index filters.
7. **Slug is always derived from `name_en`** — URL path is locale-neutral; only `?locale=el` differs for Greek.

---

## File reference

| Category | Path |
| -------- | ---- |
| SEO helper | `app/helpers/seo_helper.rb` |
| Schema helper | `app/helpers/schema_helper.rb` |
| Locale helper | `app/helpers/locale_helper.rb` |
| Skatepark model | `app/models/skatepark.rb` |
| Public controllers | `app/controllers/skateparks_controller.rb`, `app/controllers/home_controller.rb` |
| Admin controller | `app/controllers/admin/skateparks_controller.rb` |
| Application controller | `app/controllers/application_controller.rb` |
| Layout | `app/views/layouts/application.html.erb` |
| Title / description partials | `app/views/application/_title.html.erb`, `app/views/application/_description.html.erb` |
| Admin SEO form | `app/views/admin/skateparks/_form.html.erb` |
| Locale switcher | `app/views/home/_locale_selector.html.erb` |
| Locale files | `config/locales/en.yml`, `config/locales/el.yml` |
| Sitemap locale helper | `lib/sitemap_locale_helper.rb` |
| Sitemap config | `config/sitemap.rb` |
| Sitemap worker | `app/workers/sitemap_worker.rb` |
| Deploy hook | `bin/release` |
| robots.txt | `public/robots.txt` |
| Default OG image | `app/assets/images/logo-og.png` |
| Production SSL | `config/environments/production.rb` |
| URL redirects | `config/routes.rb` |
