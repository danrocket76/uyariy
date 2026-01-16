# frozen_string_literal: true

module Types
  class AudiogramType < Types::BaseObject
    field :id, ID, null: false
    field :user_id, Integer, null: false

    field :thresholds, GraphQL::Types::JSON, null: true

    field :image_file, String, null: true
    field :notes, String, null: true

    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    field :recommendations, [Types::RecommendationType], null: true
  end
end
