ActiveAdmin.register User do

  menu if: proc { current_user.admin? || current_user.audiologist? }

  permit_params :email, :password, :password_confirmation, :role, :name

  # 1. The List View (Index)
  index do
    selectable_column
    id_column
    column :name
    column :email
    column :role do |user|
      # Colors the tag based on role: Patient (grey), Audiologist (orange), Admin (red)
      status_tag user.role, class: "status_#{user.role}"
    end
    column :created_at
    actions
  end

  # 2. The Filters (Sidebar)
  filter :name
  filter :email
  filter :role, as: :select, collection: User.roles.keys

  # 3. The "Create/Edit" Form
  form do |f|
    f.inputs "User Details" do
      f.input :name
      f.input :email
      f.input :password
      f.input :password_confirmation
      f.input :role, as: :select, collection: User.roles.keys, include_blank: false
    end
    f.actions
  end

  # Fix for saving without password if not changing it
  controller do
    def update
      if params[:user][:password].blank?
        params[:user].delete("password")
        params[:user].delete("password_confirmation")
      end
      super
    end
  end
end