class HearingAidsController < ApplicationController
  # 1. Skip standard Devise login check
  #before_action :authenticate_user!, only: [:index, :show]
  # 2. Skip our custom Role check
  #skip_before_action :authenticate_patient!, only: [:index, :show]

  #before_action :authenticate_patient!, only: [:index, :show]

  def index
    @hearing_aids = HearingAid.all
  end
  def show
    @hearing_aid = HearingAid.find(params[:id])
  end
end