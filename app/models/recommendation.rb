class Recommendation < ApplicationRecord
  belongs_to :user
  belongs_to :hearing_aid
  belongs_to :audiogram

  # Status of the recommendation
  enum :status, { pending: 0, approved: 1, rejected: 2, purchased: 3, cochlear: 4 }

  def self.ransackable_attributes(auth_object = nil)
    # Add "audiogram_id" here
    ["audiogram_id", "created_at", "hearing_aid_id", "id", "notes", "status", "updated_at", "user_id", "audiologist_notes", "validated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["hearing_aid", "user", "audiogram", "recommendations"] # Ensure 'audiogram' is also here
  end
end