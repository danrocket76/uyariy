class Api::V1::RegistrationsController < Devise::RegistrationsController
  skip_before_action :verify_authenticity_token , raise: false
  respond_to :json

  def create
    build_resource(sign_up_params)
    if resource.save
      render json: { message: 'Signed up successfully', user: resource }, status: :created
    else
      render json: { errors: resource.errors.full_messages }, status: :unprocessable_entity
    end
  end
end