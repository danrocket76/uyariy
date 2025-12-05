class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # 1. We Define Roles
  enum :role, { patient: 0, audiologist: 1, admin: 2 }

  # 2. The Associations
  has_many :recommendations, dependent: :destroy

  has_many :audiograms, dependent: :destroy

  has_many :appointments, dependent: :destroy

  # 3. Validation
  validates :name, presence: true

  # 4. Set the default role to 'patient' if none is set
  after_initialize :set_default_role, if: :new_record?

  def set_default_role
    self.role ||= :patient
  end

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "email", "id", "name", "role", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["audiograms", "appointments", "recommendations"]
  end
end