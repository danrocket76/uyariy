class AddMaxGainToHearingAids < ActiveRecord::Migration[8.1]
  def change
    add_column :hearing_aids, :max_gain, :integer
  end
end
