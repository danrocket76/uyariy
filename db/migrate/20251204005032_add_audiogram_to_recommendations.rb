class AddAudiogramToRecommendations < ActiveRecord::Migration[8.1]
  def change
    add_reference :recommendations, :audiogram, null: false, foreign_key: true
  end
end
