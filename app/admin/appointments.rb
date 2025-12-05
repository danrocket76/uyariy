ActiveAdmin.register Appointment do
  permit_params :user_id, :appointment_date, :status, :reason

  # a scope to see what needs attention
  scope :all
  scope :pending
  scope :confirmed

  index do
    selectable_column
    id_column
    column :user
    column :appointment_date
    column :reason
    column :status do |appt|
      status_tag appt.status, class: "status_#{appt.status}"
    end
    actions
  end

  form do |f|
    f.inputs do
      f.input :user, input_html: { disabled: true }
      f.input :appointment_date, as: :datetime_picker
      f.input :reason
      f.input :status, as: :select, collection: Appointment.statuses.keys
    end
    f.actions
  end
end