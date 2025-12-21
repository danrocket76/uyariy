class AudiogramRegistrationFacade

  attr_reader :audiogram

  def initialize(user, params)
    @user = user
    @params = params
    @audiogram = nil
  end

  def register
    build_audiogram

    if @audiogram.save
      RecommendationFactory.create(@audiogram, @user)
      return true
    else
      return false
    end
  end

  private

  def build_audiogram
    if @params[:image_file].present?
      process_ai_upload
    else
      process_manual_input
    end
  end

  def process_ai_upload
    uploaded_file = @params[:image_file]
    @audiogram = @user.audiograms.build(notes: "Imported via AI Analysis")
    @audiogram.image_file = uploaded_file.original_filename


    extracted_data = AudiogramImageExtractor.new(uploaded_file.tempfile.path).extract_data

    if extracted_data
      @audiogram.thresholds = extracted_data
    else
      @audiogram.errors.add(:base, "AI could not read the image. Please try a clearer photo.")
    end
  end

  def process_manual_input
    thresholds = {
      left: @params[:left_ear],
      right: @params[:right_ear],
    }
    @audiogram = @user.audiograms.build(thresholds: thresholds)
  end
end