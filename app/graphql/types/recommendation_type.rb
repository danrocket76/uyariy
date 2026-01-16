# frozen_string_literal: true

module Types
  class RecommendationType < Types::BaseObject
    field :id, ID, null: false
    field :user_id, Integer, null: false
    field :hearing_aid_id, Integer
    field :notes, String
    field :status, Integer
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    field :validated_at, GraphQL::Types::ISO8601DateTime
    field :audiologist_notes, String
    field :audiogram_id, Integer, null: false
    field :hearing_aid_id, Integer

    field :hearing_aid, Types::HearingAidType, null: true
  end
end
