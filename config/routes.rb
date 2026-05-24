Rails.application.routes.draw do
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Authentication
  resource  :session, only: %i[new create destroy]
  resource  :registration, only: %i[new create]
  resources :passwords, param: :token, only: %i[new create edit update]

  # Main resources
  resources :items do
    resources :loans, only: %i[create] do
      member do
        patch :approve
        patch :decline
        patch :activate
        patch :return_item
      end
    end
  end

  # Discovery / Search
  get "search", to: "items#search", as: :search_items

  # Loans management
  resources :loans, only: %i[index show] do
    collection do
      get :my_borrows
      get :my_lends
    end
  end

  # Neighborhoods
  resources :neighborhoods, only: %i[show] do
    member do
      get :dashboard
    end
  end

  # Invitations
  resources :invitations, only: %i[new create] do
    collection do
      get "accept/:token", action: :accept, as: :accept
    end
  end

  # Notifications
  resources :notifications, only: %i[index] do
    collection do
      post :mark_all_read
    end
    member do
      patch :mark_read
    end
  end

  # Admin namespace
  namespace :admin do
    get "/", to: "dashboard#index"
    resources :members, only: %i[index destroy] do
      member do
        patch :toggle_role
      end
    end
    resources :flagged_items, only: %i[index] do
      member do
        patch :unflag
        delete :remove
      end
    end
  end

  # Root
  root "items#index"
end
