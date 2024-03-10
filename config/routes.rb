Rails.application.routes.draw do

  namespace :admin do
    resources :skateparks
  end

  if Rails.env.production?
    # 301 permant redirects
    get "/skateparks/16-xanthi" => redirect("/skateparks/21-xanthi", status: 301)
  end

  resources :skateparks

  get "healthcheck" => "rails/health#show", as: :rails_health_check

  root :to => "home#index"
  get "about"=> "home#about"
  get "contact"=> "home#contact"
end
