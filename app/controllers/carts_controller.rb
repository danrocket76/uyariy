class CartsController < ApplicationController
  before_action :authenticate_patient!
  def show
    @cart = Cart.find(params[:id])
  end
end