class AppointmentsController < ApplicationController
  before_action :authenticate_patient!

  def index
    @appointments = current_user.appointments.order(appointment_date: :desc)
  end

  def new
    @appointment = Appointment.new
  end

  def create
    @appointment = current_user.appointments.build(appointment_params)
    @appointment.status = :pending #default mode

    if @appointment.save
      redirect_to appointments_path, notice: 'Appointment requested successfully. Waiting for confirmation.'
    else
      render :new
    end
  end

  private

  def appointment_params
    params.require(:appointment).permit(:appointment_date, :reason)
  end
end