module Mutations
  class DeleteAudiogram < BaseMutation
    argument :id, ID, required: true

    field :id, ID, null: true
    field :errors, [String], null: false

    def resolve(id:)

      audiogram = context[:current_user].audiograms.find_by(id: id)

      if audiogram
        audiogram.destroy
        { id: id, errors: [] }
      else
        { id: nil, errors: ["Audiogram not found or access denied"] }
      end
    end
  end
end