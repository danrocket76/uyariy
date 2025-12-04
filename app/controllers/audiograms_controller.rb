class AudiogramsController < ApplicationController
  # Security: Only patients allowed (Admins go to Dashboard)
  before_action :authenticate_patient!

  def index
    # History: Newest first
    @audiograms = current_user.audiograms.order(created_at: :desc)
  end

  def show
    @audiogram = Audiogram.find(params[:id])
    @analysis = AudiogramAnalyzer.new(@audiogram).run

    # 1. Math: Find all devices powerful enough for the loss
    # (We use this to show the list of "Potential Matches")
    max_loss_val = [@analysis[:left_ear][:max_loss], @analysis[:right_ear][:max_loss]].max
    @math_recommendations = HearingAid.where("max_gain >= ?", max_loss_val)

    # 2. Clinical: Find actual DB records created/validated by the system or doctor
    # (We use this to check for badges, notes, and validation status)
    @clinical_recommendations = Recommendation.where(user: current_user, hearing_aid: @math_recommendations)
  end

  def new
    @audiogram = Audiogram.new
  end

  def create
    # === BRANCH 1: IMAGE UPLOAD ===
    if params[:audiogram][:image_file].present?
      uploaded_file = params[:audiogram][:image_file]
      @audiogram = current_user.audiograms.build(notes: "Imported via AI Analysis")

      @audiogram.image_file = uploaded_file.original_filename

      # AI Extraction
      extracted_data = AudiogramImageExtractor.new(uploaded_file.tempfile.path).extract_data

      if extracted_data
        @audiogram.thresholds = extracted_data
        if @audiogram.save
          auto_generate_recommendation(@audiogram) # <--- NEW LOGIC
          redirect_to @audiogram, notice: 'AI Analysis complete! Recommendation drafted.', status: :see_other
        else
          flash.now[:alert] = "Error saving AI data."
          render :new, status: :unprocessable_entity
        end
      else
        flash.now[:alert] = "AI could not read image. Please try again."
        render :new, status: :unprocessable_entity
      end

      # === BRANCH 2: MANUAL INPUT ===
    else
      thresholds = {
        left: params[:audiogram][:left_ear],
        right: params[:audiogram][:right_ear]
      }

      @audiogram = current_user.audiograms.build(thresholds: thresholds)

      if @audiogram.save
        auto_generate_recommendation(@audiogram) # <--- NEW LOGIC
        redirect_to @audiogram, notice: 'Manual audiogram saved! Recommendation drafted.', status: :see_other
      else
        render :new, status: :unprocessable_entity
      end
    end
  end

  def destroy
    @audiogram = current_user.audiograms.find(params[:id])
    @audiogram.destroy
    redirect_to audiograms_path, notice: "Assessment deleted successfully."
  end

  private

  # --- THE NEW LOGIC TO CREATE A DRAFT FOR THE AUDIOLOGIST ---
  def auto_generate_recommendation(audiogram)
    # 1. Analyze the new data
    analysis = AudiogramAnalyzer.new(audiogram).run
    max_loss = [analysis[:left_ear][:max_loss], analysis[:right_ear][:max_loss]].max

    # 2. Skip if hearing is normal (No need to waste doctor's time)
    return if max_loss < 25

    # 3. Find the "Best Fit" (Highest price/quality that covers the loss)
    # This creates the "Default" suggestion the doctor will see
    best_match = HearingAid.where("max_gain >= ?", max_loss).order(price: :desc).first

    if best_match
      # 4. Create the PENDING record
      Recommendation.create!(
        user: current_user,
        audiogram_id: audiogram.id,
        hearing_aid: best_match,
        status: :pending,
        notes: "System Auto-Selection based on #{max_loss}dB loss."
      )
    end
  end
end