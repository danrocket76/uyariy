class AudiogramsController < ApplicationController
  before_action :authenticate_patient!
  before_action :set_audiogram, only: [:show, :destroy]

  def index
    @audiograms = current_user.audiograms.order(created_at: :desc)
  end

  def show

    @analysis = AudiogramAnalyzer.new(@audiogram).analyze


    left_max = @analysis[:left_ear][:max_loss]
    right_max = @analysis[:right_ear][:max_loss]
    max_loss = [left_max, right_max].max

    if max_loss >= 90
      @math_recommendations = []
    else
      @math_recommendations = HearingAid.where("max_gain >= ? AND stock > 0", max_loss)
                                        .order(max_gain: :asc)
                                        .limit(3)
                                        .to_a
      if @math_recommendations.empty?
        @math_recommendations = HearingAid.where("stock > 0").order(max_gain: :desc).limit(3).to_a
      end
    end

    doctor_choice = @audiogram.recommendations.find { |r| r.approved? && r.hearing_aid.present? }&.hearing_aid

    if doctor_choice
      @math_recommendations.unshift(doctor_choice) unless @math_recommendations.include?(doctor_choice)
    end

    @clinical_recommendations = @audiogram.recommendations.includes(:hearing_aid)
  end

  def new
    @audiogram = Audiogram.new
  end

  def create
    @facade = AudiogramRegistrationFacade.new(current_user, params[:audiogram])

    if @facade.register
      redirect_to @facade.audiogram, notice: 'Assessment processing complete.', status: :see_other
    else

      @audiogram = @facade.audiogram || Audiogram.new
      flash.now[:alert] = @audiogram.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @audiogram.destroy
    redirect_to audiograms_path, notice: 'Audiogram deleted.'
  end

  private

  def set_audiogram
    @audiogram = current_user.audiograms.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to audiograms_path, alert: "Audiogram not found."
  end

end