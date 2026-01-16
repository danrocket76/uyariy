module Mutations
  class CreateAppointment < BaseMutation

    argument :appointment_date, GraphQL::Types::ISO8601DateTime, required: true
    argument :reason, String, required: true
    argument :hearing_aid_id, ID, required: false


    field :appointment, Types::AppointmentType, null: true
    field :errors, [String], null: false

    def resolve(appointment_date:, reason:, hearing_aid_id: nil)

      user = context[:current_user]
      return { appointment: nil, errors: ["Not authenticated"] } unless user


      appointment = user.appointments.build(
        appointment_date: appointment_date,
        reason: reason,
        hearing_aid_id: hearing_aid_id,
        status: :pending
      )


      if appointment.save
        { appointment: appointment, errors: [] }
      else
        { appointment: nil, errors: appointment.errors.full_messages }
      end
    end
  end
end