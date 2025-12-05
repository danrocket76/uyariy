class CheckoutsController < ApplicationController
  before_action :authenticate_patient!

  def create
    @cart = Cart.find(params[:cart_id])

    # Transform the cart items into the stripe format
    line_items = @cart.order_items.map do |item|
      {
        price_data: {
          currency: 'usd',
          product_data: {
            name: "#{item.hearing_aid.brand} - #{item.hearing_aid.device_model}",
            description: item.hearing_aid.technical_specs.truncate(50),
          },
          unit_amount: (item.hearing_aid.price * 100).to_i,
        },
        quantity: item.quantity,
      }
    end

    # It Creates the Session
    session = Stripe::Checkout::Session.create(
      payment_method_types: ['card'],
      line_items: line_items,
      mode: 'payment',
      success_url: checkout_success_url + '?session_id={CHECKOUT_SESSION_ID}',
      cancel_url: cart_url(@cart),
      )

    # We will send the user to stripe
    redirect_to session.url, allow_other_host: true
  end

  def success
    if session[:cart_id]
      cart = Cart.find_by(id: session[:cart_id])

      if cart
        Order.create!(
          user: current_user,
          total_amount: cart.total_price,
          status: "paid",
          stripe_payment_id: params[:session_id]
        )
        cart.order_items.each do |item|
          product = item.hearing_aid

          # This will reduce the Stock
          product.update(stock: product.stock - item.quantity)

          # Find any recommendation for this user with the selected device and mark it as purchased
          Recommendation.where(user: current_user, hearing_aid: product).update_all(status: :purchased)
        end

        cart.destroy
        session[:cart_id] = nil
      end
    end
  end
end