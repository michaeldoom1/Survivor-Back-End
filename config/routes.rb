Rails.application.routes.draw do
  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"
  devise_for :users,
             path: "",
             path_names: { sign_in: "login", sign_out: "logout", registration: "signup" },
             controllers: {
               sessions: "users/sessions",
               registrations: "users/registrations"
             }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  get "me" => "current_user#show"
  patch "me" => "current_user#update"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  resources :contestants do
    collection do
      get :scores
    end
  end
  resources :picks do
    collection do
      get :by_season
    end
  end
  resources :scoring_events
  resources :episode_scores
  resources :seasons
  resources :episode_posts, only: [ :index, :show, :create, :update, :destroy ]
  resources :memes, only: [ :create, :destroy ]
end
