Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins '*' # En producción cambiar esto por tu dominio real, para dev está bien '*'

    resource '*',
             headers: :any,
             expose: ['Authorization'], # IMPORTANTE: Permite al frontend leer el Token JWT
             methods: [:get, :post, :put, :patch, :delete, :options, :head]
  end
end