# frozen_string_literal: true

class GraphqlController < ApplicationController
  # If accessing from outside this domain, nullify the session
  # This allows for outside API access while preventing CSRF attacks,
  # but you'll have to authenticate your user separately
  # protect_from_forgery with: :null_session

  skip_before_action :verify_authenticity_token

  def execute
    variables = prepare_variables(params[:variables])
    query = params[:query]
    operation_name = params[:operationName]

    context = {
      current_user: current_user_from_token
      # Query context goes here, for example:
      # current_user: current_user,
    }
    result = HastoreadminSchema.execute(query, variables: variables, context: context, operation_name: operation_name)
    render json: result
  rescue => e
    raise e unless Rails.env.development?
    handle_error_in_development(e)
  end

  private

  #method to read token from header auth
  def current_user_from_token
    token = request.headers['Authorization']&.split(' ')&.last
    return nil unless token

    begin
      secret = ENV['DEVISE_JWT_SECRET_KEY'] || "clave_secreta_temporal_cambiar_en_produccion_123456789"
      decoded = JWT.decode(token, secret, true, algorithm: 'HS256')
      user_id = decoded[0]['sub']
      User.find(user_id)
    rescue JWT::DecodeError, ActiveRecord::RecordNotFound
      nil
    end
  end

  # Handle variables in form data, JSON body, or a blank value
  def prepare_variables(variables_param)
    case variables_param
    when String then JSON.parse(variables_param) || {}
    when Hash then variables_param
    when ActionController::Parameters then variables_param.to_unsafe_hash
    when nil then {}
    else raise ArgumentError, "Unexpected parameter: #{variables_param}"
    end
  end

  def handle_error_in_development(e)
    logger.error e.message
    logger.error e.backtrace.join("\n")
    render json: { errors: [{ message: e.message, backtrace: e.backtrace }], data: {} }, status: 500
  end
end

