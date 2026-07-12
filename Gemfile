source 'https://rubygems.org'

ruby '3.3.6'

# Pin Rails to the current 8.1 bugfix release, which includes the latest security fixes.
gem 'rails', '8.1.3'

# Use Propshaft, the new asset pipeline for Rails 8 [https://github.com/rails/propshaft]
gem 'propshaft'

# Pin net-imap for CVE-2026-47240, CVE-2026-47241, and CVE-2026-47242.
gem 'net-imap', '>= 0.6.4.1'

# Pin transitive gems for bundle-audit / pre-push security checks.
gem 'concurrent-ruby', '>= 1.3.7' # CVE-2026-54904, CVE-2026-54905, CVE-2026-54906
gem 'faraday', '>= 2.14.3' # CVE-2026-54297
gem 'msgpack', '>= 1.8.2' # CVE-2026-54522
gem 'nokogiri', '>= 1.19.4' # GHSA advisories through 1.19.3
gem 'websocket-driver', '>= 0.8.2' # CVE-2026-54463, CVE-2026-54464, CVE-2026-54465, GHSA-2x63-gw47-w4mm

# Use postgresql as the database for Active Record
gem 'pg', '~> 1.1'

# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '~> 8.0', '>= 8.0.2'

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem 'importmap-rails'

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem 'turbo-rails'

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem 'stimulus-rails'

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem 'jbuilder'

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem 'bcrypt', '~> 3.1.7'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[windows jruby]

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem 'image_processing', '~> 1.2'

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: %i[mri windows]

  gem 'pry-rails'
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem 'web-console'

  gem 'lefthook'

  gem 'actioncable'
  gem 'listen'
  gem 'lookbook'

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"

  gem 'rubocop', require: false
  gem 'rubocop-capybara', require: false
  gem 'rubocop-factory_bot', require: false
  gem 'rubocop-minitest', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false

  gem 'brakeman', require: false
  gem 'bundler-audit', require: false
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem 'capybara'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'mocha'
  gem 'rails-controller-testing'
  gem 'simplecov', require: false
end

gem 'tailwindcss-rails', '~> 4.0'

gem 'view_component', '~> 4.9'

gem 'dockerfile-rails', '~> 1.6', '>= 1.6.24'

gem 'mobility', '~> 1.3.2'

gem 'mobility-actiontext', '~> 1.1'

gem 'sitemap_generator'

gem 'activestorage-cloudinary-service'
gem 'cloudinary'

gem 'connection_pool', '~> 2.5'
gem 'redis', '~> 5.0'
gem 'sidekiq'
gem 'sidekiq-cron'

gem 'foreman', '~> 0.88.1'

gem 'countries', '~> 8.0'

gem 'kaminari'

gem 'strong_migrations'

gem 'geocoder', '~> 1.8'
