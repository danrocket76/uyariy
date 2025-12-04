class CreateAudiograms < ActiveRecord::Migration[8.1]
  def change
    create_table :audiograms do |t|
      t.references :user, null: false, foreign_key: true
      t.jsonb :thresholds, default: {}
      t.string :image_file
      t.text :notes

      t.timestamps
    end
  end
end
