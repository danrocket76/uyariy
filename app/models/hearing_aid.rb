class HearingAid < ApplicationRecord
  has_many :recommendations

  validates :brand, :model_name, :price, presence: true
  validates :stock, numericality: { greater_than_or_equal_to: 0 }

  def covers_loss?(db_loss)
    max_power = self.try(:power) || self.try(:gain) || self.try(:max_gain) || 120

    max_power.to_i >= db_loss.to_i
  end

  def self.ransackable_attributes(auth_object = nil)
    ["brand", "created_at", "device_model", "id", "price", "stock", "technical_specs", "updated_at", "max_gain"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["order_items", "recommendations"]
  end

end