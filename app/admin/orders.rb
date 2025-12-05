ActiveAdmin.register Order do
  menu priority: 4
  actions :index, :show # Read-only

  index do
    selectable_column
    id_column
    column :user
    column :total_amount do |order|
      number_to_currency order.total_amount
    end
    column :status do |order|
      status_tag order.status, class: "ok"
    end
    column :created_at
    actions
  end
end