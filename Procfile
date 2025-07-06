web: rm -f tmp/pids/server.pid && bundle exec rake db:migrate && bin/rails server -b 0.0.0.0 -p ${PORT:-3000}
worker: bundle exec sidekiq -e $RAILS_ENV
