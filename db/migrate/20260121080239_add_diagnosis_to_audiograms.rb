class AddDiagnosisToAudiograms < ActiveRecord::Migration[8.1]
  def change
    add_column :audiograms, :diagnosis, :string
    add_column :audiograms, :date, :datetime
  end
end
