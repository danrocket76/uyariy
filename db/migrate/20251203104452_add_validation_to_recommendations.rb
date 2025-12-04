class AddValidationToRecommendations < ActiveRecord::Migration[8.1]
  def change
    add_column :recommendations, :validated_at, :datetime
    add_column :recommendations, :audiologist_notes, :text
  end
end
