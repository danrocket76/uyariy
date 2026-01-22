# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    field :create_appointment, mutation: Mutations::CreateAppointment
    field :create_audiogram, mutation: Mutations::CreateAudiogram
    field :delete_audiogram, mutation: Mutations::DeleteAudiogram
  end
end
