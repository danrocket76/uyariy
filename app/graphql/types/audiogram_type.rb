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




    field :diagnosis, String, null: true


    field :date, GraphQL::Types::ISO8601DateTime, null: true

    def date

      object.respond_to?(:date) && object.date.present? ? object.date : object.created_at
    end


    field :frequencies, [Integer], null: true


    def frequencies
      #if not hash, return empty
      return [] unless object.thresholds.is_a?(Hash)

      standard_keys = %w[125 250 500 1000 2000 4000 8000]
      ordered_values = standard_keys.map { |k| object.thresholds[k] || object.thresholds[k.to_sym] }


      if ordered_values.any? { |v| v.present? }
        return ordered_values.map do |v|
          (v.is_a?(Numeric) || v.is_a?(String)) ? v.to_i : 0
        end
      end

      object.thresholds.values.map do |val|
        (val.is_a?(Numeric) || val.is_a?(String)) ? val.to_i : 0
      end
    end

  end
end