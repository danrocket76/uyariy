class HearingAid < ApplicationRecord
  has_many :recommendations

  validates :brand, :model_name, :price, presence: true
  validates :stock, numericality: { greater_than_or_equal_to: 0 }

  def self.ransackable_attributes(auth_object = nil)
    ["brand", "created_at", "device_model", "id", "price", "stock", "technical_specs", "updated_at", "max_gain"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["order_items", "recommendations"]
  end

end