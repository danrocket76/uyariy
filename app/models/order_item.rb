class OrderItem < ApplicationRecord
  belongs_to :hearing_aid
  belongs_to :cart

  def total_price
    quantity * hearing_aid.price
  end
end