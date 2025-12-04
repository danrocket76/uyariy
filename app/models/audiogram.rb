class Audiogram < ApplicationRecord
  belongs_to :user
  has_many :recommendations, dependent: :destroy

  # 1. Allow searching these columns (Date, ID, Notes)
  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "id", "notes", "updated_at", "user_id", "image_file", "thresholds"]
  end

  # 2. Allow searching the "User" association (So Admin can filter by Patient Name)
  def self.ransackable_associations(auth_object = nil)
    ["user"]
  end

end
