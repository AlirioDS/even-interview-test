Rails.application.routes.draw do
  # Web interface routes (if needed later)
  resource :session
  resources :passwords, param: :token
  
  # API routes
  namespace :api do
    # Public routes (no authentication required)
    namespace :public do
      resources :releases, only: [:index, :show]
    end

    namespace :v1 do
      # Authentication routes
      scope :auth do
        post :login, to: 'authentication#login'
        post :register, to: 'authentication#register'
        post :refresh, to: 'authentication#refresh'
        delete :logout, to: 'authentication#logout'
        get :me, to: 'authentication#me'
      end

      # User management routes
      resources :users do
        member do
          patch :change_role
        end
      end

      # Releases routes (authenticated)
      resources :releases, only: [:index, :show]
    end
  end
  
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
