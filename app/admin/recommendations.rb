ActiveAdmin.register Recommendation do
  menu priority: 3

  # Allow the new status (cochlear) to be saved
  permit_params :user_id, :hearing_aid_id, :status, :notes, :audiologist_notes, :validated_at, :audiogram_id

  scope :all
  scope("Pending Validation") { |scope| scope.where(validated_at: nil) }
  scope("Validated") { |scope| scope.where.not(validated_at: nil) }

  index do
    selectable_column
    id_column
    column :user
    column "Type" do |rec|
      rec.cochlear? ? status_tag("Specialist Referral", class: :error) : rec.hearing_aid&.device_model
    end
    column "Status" do |rec|
      if rec.validated_at.present?
        status_tag "Validated", class: :ok
      else
        status_tag "Pending Check", class: :warn
      end
    end
    actions
  end

  form do |f|
    f.inputs "Clinical Validation" do
      f.input :user, input_html: { disabled: true }

      f.input :audiogram, as: :select, collection: Audiogram.where(user: f.object.user).map { |a| ["Test from #{a.created_at.strftime('%b %d')}", a.id] }, input_html: { disabled: true }

      f.input :status, as: :select, collection: Recommendation.statuses.keys.map { |k| [k.humanize, k] }, include_blank: false

      li "Note: Select 'Cochlear' if the loss is too profound (95dB+). This hides the product list."

      f.input :hearing_aid, collection: HearingAid.all.map { |h| ["#{h.brand} - #{h.device_model} (Gain: #{h.max_gain}dB)", h.id] }

      f.input :audiologist_notes, label: "Clinical Message", placeholder: "e.g., Due to the profound nature of your hearing loss..."

      if object.validated_at
        f.li "Validated on: #{object.validated_at}"
      end
    end
    f.actions
  end

  controller do
    def update
      if current_user.audiologist?
        params[:recommendation][:validated_at] = Time.now
      end
      super
    end
  end
end