Rails.application.routes.draw do

  namespace :admin do
    resources :skateparks
  end

  resources :skateparks

  get "healthcheck" => "rails/health#show", as: :rails_health_check

  root :to => "home#index"
  get "about"=> "home#about"
  get "contact"=> "home#contact"
end
