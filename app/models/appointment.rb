class Appointment < ApplicationRecord
  belongs_to :user

  #new modification vinculation product and diagnosis
  belongs_to :audiogram, optional: true
  belongs_to :hearing_aid, optional: true

  enum :status, { pending:0, confirmed:1, completed: 2, cancelled: 3 }

  validates :appointment_date, presence: true
  validates :reason, presence: true

  def self.ransackable_attributes(auth_object = nil)
    ["appointment_date", "created_at", "id", "reason", "status", "updated_at", "user_id", "audiogram_id", "hearing_aid_id"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["user", "audiogram", "hearing_aid"]
  end
end
