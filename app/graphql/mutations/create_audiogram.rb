module Mutations
  class CreateAudiogram < BaseMutation
    argument :thresholds, GraphQL::Types::JSON, required: true
    argument :diagnosis, String, required: false
    argument :notes, String, required: false

    field :audiogram, Types::AudiogramType, null: true
    field :errors, [String], null: false

    def resolve(thresholds:, diagnosis: nil, notes: nil)
      return { audiogram: nil, errors: ["Not authenticated"] } unless context[:current_user]


      audiogram = context[:current_user].audiograms.build(
        thresholds: thresholds,
        diagnosis: diagnosis,
        notes: notes,
        date: Time.current
      )

      if audiogram.save
        # 2. DELEGATION: Pass logic to the Service (Dependency Injection / Service Pattern)
        # This satisfies the Open/Closed Principle: We can change the service logic
        # without changing this mutation file.
        begin
          AudiogramRecommendationService.new(audiogram).call
        rescue => e
          puts "⚠️ Service Error: #{e.message}"
        end

        { audiogram: audiogram, errors: [] }
      else
        { audiogram: nil, errors: audiogram.errors.full_messages }
      end
    end
  end
end