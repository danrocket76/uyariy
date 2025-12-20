class AudiogramsController < ApplicationController
  # Security: Only patients allowed (Admins go to Dashboard)
  before_action :authenticate_patient!
  before_action :set_audiogram, only: [:show, :destroy]
  def index
    @audiograms = current_user.audiograms.order(created_at: :desc)
  end

  def show
    #@audiogram = Audiogram.find(params[:id])
    @analysis = AudiogramAnalyzer.new(@audiogram).run

    left_max = @analysis[:left_ear][:max_loss]
    right_max = @analysis[:right_ear][:max_loss]
    max_loss = [left_max, right_max].max

    @clinical_recommendations = @audiogram.recommendations.includes(:hearing_aid)

    if max_loss >= 90
      @math_recommendations = []
    else
      @math_recommendations = HearingAid.where("max_gain >= ? AND stock >0", max_loss)
                                        .order(max_gain: :asc)
                                        .limit(3)
      if @math_recommendations.empty?
        @math_recommendations = HearingAid.where("stock > 0").order(max_gain: :desc).limit(3)
      end
    end
  end
    # 1. Math: Find all devices that can be a potential match and powerful enough for the loss
    #max_loss_val = [@analysis[:left_ear][:max_loss], @analysis[:right_ear][:max_loss]].max
    #@math_recommendations = HearingAid.where("max_gain >= ?", max_loss_val)

    # 2. Clinical: Find actual DB records created/validated by the system or doctor
  #@clinical_recommendations = Recommendation.where(user: current_user, hearing_aid: @math_recommendations)
  #end

  def new
    @audiogram = Audiogram.new
  end

  def create
    # === IMAGE UPLOAD ===
    if params[:audiogram][:image_file].present?
      uploaded_file = params[:audiogram][:image_file]
      @audiogram = current_user.audiograms.build(notes: "Imported via AI Analysis")

      @audiogram.image_file = uploaded_file.original_filename

      # AI Extraction
      extracted_data = AudiogramImageExtractor.new(uploaded_file.tempfile.path).extract_data

      if extracted_data
        @audiogram.thresholds = extracted_data
        if @audiogram.save
          auto_generate_recommendation(@audiogram)
          redirect_to @audiogram, notice: 'AI Analysis complete! Recommendation drafted.', status: :see_other
        else
          flash.now[:alert] = "Error saving AI data."
          render :new, status: :unprocessable_entity
        end
      else
        flash.now[:alert] = "AI could not read image. Please try a clearer photo or manual input."
        render :new, status: :unprocessable_entity
      end

      # MANUAL INPUT
    else
      thresholds = {
        left: params[:audiogram][:left_ear],
        right: params[:audiogram][:right_ear]
      }

      @audiogram = current_user.audiograms.build(thresholds: thresholds)

      if @audiogram.save
        auto_generate_recommendation(@audiogram)
        redirect_to @audiogram, notice: 'Manual audiogram saved! Recommendation drafted.', status: :see_other
      else
        render :new, status: :unprocessable_entity
      end
    end
  end

  def destroy
    #@audiogram = current_user.audiograms.find(params[:id])
    @audiogram.destroy
    redirect_to audiograms_path, notice: "Assessment deleted successfully."
  end

  private
  def set_audiogram
    @audiogram = current_user.audiograms.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to audiogram_path, alert: "Audiogram not found"
  end

  # CREATES A DRAFT OF THE RECOMMENDATION FOR THE AUDIOLOGIST
  def auto_generate_recommendation(audiogram)
    # 1. Calculate the patient's worst hearing loss (Max Decibels)
    # We look at both ears and find the highest number
    left_vals = audiogram.thresholds.dig('left').values.map(&:to_i)
    right_vals = audiogram.thresholds.dig('right').values.map(&:to_i)

    #left_max = audiogram.thresholds.dig("left").values.map(&:to_i).max || 0
    #right_max = audiogram.thresholds.dig("right").values.map(&:to_i).max || 0

    left_max = left_vals.any? ? left_vals.max : 0
    right_max = right_vals.any? ? right_vals.max : 0
    max_loss = [left_max, right_max].max

    # 2. Logic Gate: Is it Profound Loss? (> 90dB)
    # If yes, we don't recommend a standard hearing aid. We flag for Cochlear.
    if max_loss >= 90
      Recommendation.create!(
        user: current_user,
        audiogram: audiogram,
        status: :pending,
        hearing_aid: nil, # No specific device
        audiologist_notes: "System Alert: Profound loss detected (#{max_loss}dB). Cochlear Implant evaluation recommended."
      )
      return
    end

    # 3. SMART QUERY (The Fix)
    # Find devices that cover the loss ("max_gain >= max_loss")
    # AND sort by 'max_gain ASC' to pick the closest fit, not the most powerful one.
    best_match = HearingAid.where("max_gain >= ? AND stock > 0", max_loss)
                           .order(max_gain: :asc)
                           .first

    # 4. Fallback: If no perfect match, just get the most powerful one we have
    best_match ||= HearingAid.where("stock > 0").order(max_gain: :desc).first

    # 5. Create the Recommendation
    if best_match
      Recommendation.create!(
        user: current_user,
        audiogram: audiogram,
        hearing_aid: best_match,
        status: :pending,
        notes: "System Auto-Selection based on #{max_loss}dB loss. Matched with #{best_match.device_model} (Gain: #{best_match.max_gain}dB)."
      )
    else
      # Edge case: Empty Inventory
      Recommendation.create!(
        user: current_user,
        audiogram: audiogram,
        status: :pending,
        notes: "System Alert: No suitable inventory found for #{max_loss}dB loss."
      )
    end
  end
end