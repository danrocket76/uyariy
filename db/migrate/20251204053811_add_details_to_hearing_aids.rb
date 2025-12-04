class AddDetailsToHearingAids < ActiveRecord::Migration[8.1]
  def change
    add_column :hearing_aids, :image_url, :string
    add_column :hearing_aids, :features, :text
    add_column :hearing_aids, :battery_type, :string
    add_column :hearing_aids, :bluetooth, :boolean
    add_column :hearing_aids, :warranty, :string
  end
end
