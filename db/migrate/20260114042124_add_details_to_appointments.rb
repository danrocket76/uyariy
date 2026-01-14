class AddDetailsToAppointments < ActiveRecord::Migration[8.1]
  def change
    add_reference :appointments, :audiogram, null: true, foreign_key: true
    add_reference :appointments, :hearing_aid, null: true, foreign_key: true
  end
end
