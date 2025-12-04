class Cart < ApplicationRecord
  has_many :order_items, dependent: :destroy
  has_many :hearing_aids, through: :order_items

  def total_price
    order_items.joins(:hearing_aid).sum("order_items.quantity * hearing_aids.price")
  end
end