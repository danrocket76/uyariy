class RecommendationFactory
  def self.create(audiogram, user)
    new(audiogram, user).build
  end

  def initialize(audiogram, user)
    @audiogram = audiogram
    @user = user
  end

  def build
    max_loss = calculate_max_loss

    if profound_loss?(max_loss)
      create_cochlear_recommendation(max_loss)
    else
      create_hearing_aid_recommendation(max_loss)
    end
  end

  private
  def calculate_max_loss

    left_max = @audiogram.thresholds.dig("left").values.map(&:to_i).max || 0
    right_max = @audiogram.thresholds.dig("right").values.map(&:to_i).max || 0
    [left_max, right_max].max
  end

  def profound_loss?(loss)
    loss >= 90
  end

  def create_cochlear_recommendation(loss)
    Recommendation.create!(
      user: @user,
      audiogram: @audiogram,
      status: :pending,
      hearing_aid: nil,
      audiologist_notes: "System Alert: Profound loss detected (#{loss}dB). Cochlear Implant evaluation recommended."
    )
  end

  def create_hearing_aid_recommendation(loss)
    best_match = HearingAid.where("max_gain >= ? AND stock > 0", loss)
                           .order(max_gain: :asc)
                           .first

    best_match ||= HearingAid.where("stock > 0").order(max_gain: :desc).first

    if best_match
      Recommendation.create!(
        user: @user,
        audiogram: @audiogram,
        hearing_aid: best_match,
        status: :pending,
        notes: "System Auto-Selection based on #{loss}dB loss. Matched with #{best_match.device_model}."
      )
    else
      Recommendation.create!(
        user: @user,
        audiogram: @audiogram,
        status: :pending,
        notes: "System Alert: No suitable inventory found for #{loss}dB loss."
      )
    end
  end
end