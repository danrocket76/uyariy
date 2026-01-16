Rails.application.routes.draw do
  if Rails.env.development?
    mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/graphql"
  end
  post "/graphql", to: "graphql#execute"
  get "pages/home"
  devise_for :users, path: '',
             path_names: {
               sign_in: 'api/v1/login',
               sign_out: 'api/v1/logout',
               registration: 'api/v1/signup'
             },
             controllers: {sessions: "api/v1/sessions", registrations: "api/v1/registrations"}
  ActiveAdmin.routes(self)
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  root to: "pages#home"

  resources :audiograms

  resources :hearing_aids, only: [:index, :show]

  resources :carts, only: [:show]

  resources :order_items, only: [:create, :destroy]

  resources :checkouts, only: [:create]
  get 'checkout/success', to: 'checkouts#success'

  resources :appointments, only: [:index, :new, :create]


  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"



end
