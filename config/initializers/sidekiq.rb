require 'sidekiq/web'
require 'sidekiq/cron/web'

schedule_file = 'config/schedule.yml'

redis_config = { url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/1') }

Sidekiq.configure_server do |config|
  config.redis = redis_config
end

Sidekiq.configure_client do |config|
  config.redis = redis_config
end

Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file) if File.exist?(schedule_file) && Sidekiq.server?
