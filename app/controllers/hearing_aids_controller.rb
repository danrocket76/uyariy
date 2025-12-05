class HearingAidsController < ApplicationController
  # before_action :authenticate_user!, only: [:index, :show]
  # skip_before_action :authenticate_patient!, only: [:index, :show]
  # before_action :authenticate_patient!, only: [:index, :show]

  def index
    @hearing_aids = HearingAid.all
  end
  def show
    @hearing_aid = HearingAid.find(params[:id])
  end
end