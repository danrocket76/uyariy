class AudiogramRecommendationService
  def initialize(audiogram)
    @audiogram = audiogram
    @thresholds = audiogram.thresholds
    @user = audiogram.user
  end

  def call
    return unless @thresholds


    avg_loss = calculate_pta
    puts "🧮 Service Calculated PTA: #{avg_loss} dB"


    if avg_loss > 25 && avg_loss < 90
      generate_recommendations(avg_loss)
    end
  end

  private

  def calculate_pta

    safe_data = @thresholds.is_a?(Hash) ? @thresholds : @thresholds.to_unsafe_h
    safe_data = safe_data.deep_stringify_keys

    right_vals = safe_data.dig("right")&.values || []
    left_vals  = safe_data.dig("left")&.values  || []


    if right_vals.empty? && left_vals.empty?
      right_vals = safe_data.values
    end

    all_values = (right_vals + left_vals).map { |v|
      v.to_i if (v.is_a?(Numeric) || (v.is_a?(String) && v.match?(/\A-?\d+\z/)))
    }.compact

    return 0 if all_values.empty?
    all_values.sum / all_values.size
  end

  def generate_recommendations(avg_loss)

    stock_aids = HearingAid.where("stock > 0")


    compatible_aids = stock_aids.select do |aid|
      #max_power = aid.try(:power) || aid.try(:gain) || aid.try(:max_gain) || 120
      #max_power.to_i >= avg_loss
      #after information expert principle
      aid.covers_loss?(avg_loss)
    end

    compatible_aids.each do |aid|
      Recommendation.create(audiogram: @audiogram, hearing_aid: aid, user: @user)
    end
  end
end