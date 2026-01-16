class Api::V1::SessionsController < Devise::SessionsController
  skip_before_action :verify_authenticity_token, raise: false
  respond_to :json

  private

  def respond_with(resource, _opts = {})
    render json: {
      message: 'Logged in successfully.',
      user: {
        id: resource.id,
        email: resource.email,
        # IMPORTANTE: Enviamos el rol para redirigir en el frontend
        role: resource.role || 'patient'
      },
      token: request.env['warden-jwt_auth.token']
    }, status: :ok
  end

  def respond_to_on_destroy
    if current_user
      render json: { message: "Logged out successfully" }, status: :ok
    else
      render json: { message: "Couldn't find an active session." }, status: :unauthorized
    end
  end
end