class Audiogram < ApplicationRecord
  belongs_to :user

  has_many :recommendations, dependent: :destroy

  has_many :appointments, dependent: :nullify

  validates :thresholds, presence: true

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "id", "notes", "updated_at", "user_id", "image_file", "thresholds"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["user"]
  end

end
