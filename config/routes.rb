Rails.application.routes.draw do
  # --- 1. API (Para tu Next.js Frontend) ---
  # Aquí vive toda la lógica del paciente
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      devise_scope :user do
        post 'login', to: 'sessions#create'
        delete 'logout', to: 'sessions#destroy'
        post 'signup', to: 'registrations#create'
      end
      # Tu ruta de IA
      post 'analyze_audiogram', to: 'ai_diagnostic#analyze'
    end
  end

  # --- 2. GRAPHQL ---
  if Rails.env.development?
    mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/graphql"
  end
  post "/graphql", to: "graphql#execute"

  # --- 3. FRONTEND CLÁSICO (HTML / Admin) ---
  # Esto arregla el login del doctor (vuelve a ser normal)
  devise_for :users
  ActiveAdmin.routes(self)

  # Rutas de tus recursos existentes (Audiogramas, Citas, etc.)
  resources :audiograms
  resources :hearing_aids, only: [:index, :show]
  resources :carts, only: [:show]
  resources :order_items, only: [:create, :destroy]
  resources :checkouts, only: [:create]
  get 'checkout/success', to: 'checkouts#success'
  resources :appointments, only: [:index, :new, :create]

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # --- 4. LA RAÍZ DEL PROBLEMA (Solucionada) ---
  # Eliminé "home#index" que no existe.
  # Volvemos a tu página original que SI funcionaba:
  root to: "pages#home"

  # Si no tienes PagesController, usa el dashboard de admin como home:
  # root to: "admin/dashboard#index"
end