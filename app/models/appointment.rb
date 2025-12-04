class Appointment < ApplicationRecord
  belongs_to :user

  enum :status, { pending:0, confirmed:1, completed: 2, cancelled: 3 }

  validates :appointment_date, presence: true
  validates :reason, presence: true

  def self.ransackable_attributes(auth_object = nil)
    ["appointment_date", "created_at", "id", "reason", "status", "updated_at", "user_id"]
  end

  def
    self.ransackable_associations(auth_object = nil)
    ["user"]
  end
end
