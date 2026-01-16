# frozen_string_literal: true

module Types
  class AppointmentType < Types::BaseObject
    field :id, ID, null: false
    field :user_id, Integer, null: false
    field :appointment_date, GraphQL::Types::ISO8601DateTime, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    field :status, String, null: true
    field :reason, String, null: true

    field :audiogram, Types::AudiogramType, null: true
    field :hearing_aid, Types::HearingAidType, null: true
  end
end
