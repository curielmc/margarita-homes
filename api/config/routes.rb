Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      # Public
      resources :properties, only: [:index, :show]
      resources :zones, only: [:index, :show]
      resources :buildings, only: [:index, :show]

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
        resources :buildings

        post "market_snapshots/generate", to: "market_snapshots#generate"
      end
    end

    # Jasper API - Full programmatic access for AI assistant
    namespace :jasper do
      # Properties - full CRUD + bulk operations
      resources :properties do
        collection do
          post :bulk_create
          get :stats
        end
        member do
          post :add_photos
          post :mark_sold
        end
        resources :price_histories, only: [:index, :create, :destroy]
      end

      # Zones - full CRUD + property listing
      resources :zones do
        member do
          get :properties
        end
      end

      # Buildings - full CRUD + property assignment
      resources :buildings do
        member do
          post :assign_properties
          get :properties
        end
      end

      # Market data
      get "market/summary", to: "market#summary"
      get "market/trends", to: "market#trends"
      post "market/snapshot", to: "market#create_snapshot"
    end
  end
end
