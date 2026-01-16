module Types
  class HearingAidType < Types::BaseObject
    field :id, ID, null: false
    field :brand, String, null: true
    field :device_model, String, null: true
    field :price, Float, null: true
    field :stock, Integer, null: true
    field :image_url, String, null: true


    field :technical_specs, String, null: true
    field :features, String, null: true
    field :max_gain, Integer, null: true
    field :battery_type, String, null: true
    field :bluetooth, Boolean, null: true
    field :warranty, String, null: true


    field :description, String, null: true

    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false


    def description
      object.respond_to?(:description) && object.description.present? ? object.description : object.technical_specs
    end
  end
end