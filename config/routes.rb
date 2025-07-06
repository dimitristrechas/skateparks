require 'sidekiq/web'
require 'sidekiq/cron/web'

Rails.application.routes.draw do
  namespace :admin do
    resources :skateparks

    Sidekiq::Web.use Rack::Auth::Basic do |username, password|
      ActiveSupport::SecurityUtils.secure_compare(username, Rails.application.credentials.dig(:admin, :username)) &&
        ActiveSupport::SecurityUtils.secure_compare(password, Rails.application.credentials.dig(:admin, :password))
    end
    mount Sidekiq::Web => '/sidekiq'

    get 'states/:country_code', to: 'skateparks#states'
  end

  if Rails.env.production?
    # 301 permanent redirects
    get '/skateparks/16-xanthi' => redirect('/skateparks/21-xanthi', status: 301)
    get '/skateparks/32-elefsina' => redirect('/skateparks/35-elefsina', status: 301)
  end

  resources :skateparks

  get 'healthcheck' => 'rails/health#show', as: :rails_health_check

  root to: 'home#index'
  get 'about' => 'home#about'
  get 'contact' => 'home#contact'
end
