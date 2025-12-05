class PagesController < ApplicationController
  # skip_before_action :authenticate_patient!, only: [:home]
  # skip_before_action :set_cart, only: [:home] # Optional: load cart if you want, but might trigger session creation

  def home
    # We will fetch 3 premium products for the showcase in the store
    @featured_products = HearingAid.where("stock > 0").limit(3)
  end
end