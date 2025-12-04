class OrderItemsController < ApplicationController
  def create
    @hearing_aid = HearingAid.find(params[:hearing_aid_id])
    @order_item = @cart.order_items.find_by(hearing_aid: @hearing_aid)

    if @order_item
      @order_item.increment!(:quantity)
    else
      @order_item = @cart.order_items.build(hearing_aid: @hearing_aid, quantity: 1)
    end

    if @order_item.save
      redirect_to cart_path(@cart), notice: 'Added to cart.'
    else
      redirect_to @hearing_aid, alert: 'Could not add to cart.'
    end
  end

  def destroy
    @order_item = @cart.order_items.find(params[:id])
    @order_item.destroy
    redirect_to cart_path(@cart), notice: 'Item removed.'
  end
end