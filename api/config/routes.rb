Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      # Public
      resources :properties, only: [:index, :show]
      resources :zones, only: [:index, :show]

      get "market/overview", to: "market#overview"
      get "market/trends", to: "market#trends"

      # Admin
      namespace :admin do
        post "sessions", to: "sessions#create"
        delete "sessions", to: "sessions#destroy"

        resources :properties, only: [:index, :show, :create, :update, :destroy] do
          resources :price_histories, only: [:create, :destroy]
        end

        resources :zones, only: [:create, :update, :destroy]

        post "market_snapshots/generate", to: "market_snapshots#generate"
      end
    end
  end
end
