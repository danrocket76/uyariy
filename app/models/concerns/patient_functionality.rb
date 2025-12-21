module PatientFunctionality
  extend ActiveSupport::Concern

  included do

    has_many :audiograms, dependent: :destroy
    has_many :recommendations, dependent: :destroy
    has_many :appointments, dependent: :destroy

  end

  def has_pending_assessments?
    audiograms.exists? && recommendations.where(status: :pending).exists?
  end
end