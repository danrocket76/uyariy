class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # 1. PERMIT NAME FIELD (Fixes "Name can't be blank")
  before_action :configure_permitted_parameters, if: :devise_controller?

  # 2. SET CART (Ensures shopping cart works on every page)
  before_action :set_cart

  # 3. ADMIN SECURITY (For ActiveAdmin)
  def authenticate_admin_user!
    authenticate_user! # Ensure user is logged in via Devise

    # Check Role: Only Admins and Audiologists allowed in the Panel
    unless current_user.admin? || current_user.audiologist?
      flash[:alert] = "You are not authorized to access this area."
      sign_out current_user # Force logout
      redirect_to new_user_session_path # Send back to login
    end
  end

  def current_admin_user
    current_user
  end

  def authenticate_patient!
    authenticate_user!

    if current_user.admin? || current_user.audiologist?
      flash[:alert] = "Staff members cannot access patient portals. Please use the Admin Panel."
      redirect_to admin_dashboard_path
    end
  end

  protected

  # Logic to whitelist ':name' for Sign Up and Update
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end

  def after_sign_in_path_for(resource)
    if resource.admin?
      admin_dashboard_path
    elsif resource.audiologist?
      admin_appointments_path
    else
      audiograms_path
    end
  end

  private

  # Cart Logic
  def set_cart
    if session[:cart_id]
      @cart = Cart.find_by(id: session[:cart_id])
    end

    if @cart.nil?
      @cart = Cart.create
      session[:cart_id] = @cart.id
    end
  end

end