Rails.application.routes.draw do
  
  scope '/admin' do
    resources :skateparks
  end

  get "healthcheck" => "rails/health#show", as: :rails_health_check

  root :to => "static#index"
end
