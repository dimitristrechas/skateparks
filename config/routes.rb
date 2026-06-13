Rails.application.routes.draw do
  resource :session
  resources :password_resets, param: :token
  mount Lookbook::Engine, at: '/lookbook' if Rails.env.development?

  namespace :account do
    resource :profile, only: %i[show edit update]
    resource :password, only: %i[edit update]
  end

  namespace :admin do
    root to: 'dashboard#index'
    resources :skateparks
    resources :popular_skateparks, only: %i[index create update destroy], path: 'skateparks_popular'
    resources :users, only: %i[index show] do
      member do
        post :ban
        post :unban
      end
    end

    constraints lambda { |request|
      session_token = request.cookie_jar.signed[:session_token]
      session = Session.find_by(session_token: session_token) if session_token
      session && !session.expired? && session.user.active? && session.user.admin?
    } do
      mount Sidekiq::Web => '/sidekiq'
    end

    get 'states/:country_code', to: 'skateparks#states'
  end

  if Rails.env.production?
    # 301 permanent redirects
    get '/skateparks/16-xanthi' => redirect('/skateparks/21-xanthi', status: 301)
    get '/skateparks/32-elefsina' => redirect('/skateparks/35-elefsina', status: 301)
  end

  resources :skateparks

  get 'available_states(/:country_code)', to: 'skateparks#available_states'

  get 'healthcheck' => 'rails/health#show', as: :rails_health_check

  root to: 'home#index'
  get 'about' => 'home#about'
  get 'contact' => 'home#contact'
  get 'privacy' => 'home#privacy'
end
