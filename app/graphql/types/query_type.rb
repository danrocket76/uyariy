# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    include GraphQL::Types::Relay::HasNodeField
    include GraphQL::Types::Relay::HasNodesField

    field :my_audiograms, [Types::AudiogramType], null: false do
      description "Returns a list of audiograms belonging to the authenticated user"
    end

    def my_audiograms
      #security check
      return [] unless context[:current_user]
      #fetch data
      context[:current_user].audiograms.order(created_at: :desc)
    end

    field :my_appointments, [Types::AppointmentType], null: false do
      description "Returns a list of appointments belonging to the authenticated user"
    end

    def my_appointments
      return [] unless context[:current_user]

      context[:current_user].appointments
                            .includes(:audiogram, :hearing_aid)
                            .order(appointment_date: :desc)

    end

    field :hearing_aids, [Types::HearingAidType], null: false do
      description "Returns the full catalog of available Hearing Aids"
    end

    def hearing_aids
      HearingAid.where("stock > 0").order(price: :asc)
    end

    field :audiogram, Types::AudiogramType, null: true do
      description "Find a specific audiogram by ID (Security: Must belong to user)"
      argument :id, ID, required: true
    end

    def audiogram(id:)
      return nil unless context[:current_user]
      context[:current_user].audiograms.find_by(id: id)
    end
  end
end


