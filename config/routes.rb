Rails.application.routes.draw do

  namespace :admin do
    resources :skateparks
  end

  resources :skateparks

  get "healthcheck" => "rails/health#show", as: :rails_health_check

  root :to => "static#index"
end
