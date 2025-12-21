class MakeHearingAidIdNullableInRecommendations < ActiveRecord::Migration[8.1]
  def change
    change_column_null :recommendations, :hearing_aid_id, true
  end
end