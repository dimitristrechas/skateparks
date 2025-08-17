# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Development Server
- `sh scripts.sh` then select option (3): Builds and starts the development server with fresh docker build, it uses the docker-compose.development.yml and Dockerfile.dev files
- `sh scripts.sh` then select option (1): Start an existing development server via docker, it uses the docker-compose.development.yml and Dockerfile.dev files
- `sh scripts.sh` then select option (6): Connect to Docker console for debugging

### Testing
- `sh scripts.sh` then select option (9): Connect to test Docker console
- Inside test console: `bundle exec rake spec` to run RSpec tests

### Database Operations
- `sh scripts.sh` then select option (5): Rails console for database queries
- `sh scripts.sh` then select option (12): Seed the database

### Code Formatting
- `sh scripts.sh` then select option (11): Format ERB files with erb-format
- `bundle exec rubocop`: Run Ruby linter
- `yarn prettier`: Format JavaScript/CSS files

## Architecture Overview

This is a Rails 8.0 application for cataloging skateparks with the following key features:

### Core Models
- **Skatepark**: Main entity with multilingual support (Greek/English)
  - Location data (lat/lng, country_code, state)
  - Image attachments (cover_image + multiple images)
  - Rich text descriptions via ActionText
  - Status enum (draft/published/archived)
  - Slug-based URLs

### Internationalization
- **Mobility gem**: Handles translations for name and description fields
- Locales: Greek (el) and English (en)
- Country/state data using ISO3166 gem with subdivisions

### Key Technologies
- **Rails 8.0** with PostgreSQL database
- **Docker** for development/test environments
- **Tailwind CSS** + Flowbite for styling
- **ViewComponent** for reusable UI components
- **Stimulus** controllers for JavaScript interactions
- **Sidekiq** for background jobs with cron scheduling
- **Cloudinary** for image storage and processing
- **Kaminari** for pagination

### Controllers Structure
- `SkateparksController`: Public listing and detail pages with filtering
- `Admin::SkateparksController` (assumed): Admin interface
- `HomeController`: Static pages (about, contact)

### Data Flow
- Skateparks are filtered by published status
- Country/state filtering with caching
- Location-friendly names with emoji flags
- SEO-optimized meta tags per skatepark

### Environment Setup
1. Clone repository
2. `bundle install` && `npm install`
3. Copy `.env.example` to `.env` and configure
4. Use `scripts.sh` for Docker-based development
5. Database seeding available via script menu

The application uses a Docker-first development approach with all operations handled through the interactive `scripts.sh` menu system.
