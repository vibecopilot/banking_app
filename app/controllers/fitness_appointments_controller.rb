class FitnessAppointmentsController < ApplicationController
  include UserExt
  layout 'basic'
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_fitness_appointment, only: %i[ show edit update destroy ]

  # GET /fitness_appointments or /fitness_appointments.json
  def index
    @fitness_appointments = FitnessAppointment.all.order(created_at: :DESC)
  end

  # GET /fitness_appointments/1 or /fitness_appointments/1.json
  def show
  end

  # GET /fitness_appointments/new
  def new
    @fitness_appointment = FitnessAppointment.new
  end

  # GET /fitness_appointments/1/edit
  def edit
  end

  # POST /fitness_appointments or /fitness_appointments.json
  def create
    @fitness_appointment = FitnessAppointment.new(fitness_appointment_params)
    @fitness_appointment.created_by_id = @user.id


    respond_to do |format|
      if @fitness_appointment.save
        format.html { redirect_to @fitness_appointment, notice: "Fitness appointment was successfully created." }
        format.json { render :show, status: :created, location: @fitness_appointment }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @fitness_appointment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /fitness_appointments/1 or /fitness_appointments/1.json
  def update
    respond_to do |format|
      if @fitness_appointment.update(fitness_appointment_params)
        format.html { redirect_to @fitness_appointment, notice: "Fitness appointment was successfully updated." }
        format.json { render :show, status: :ok, location: @fitness_appointment }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @fitness_appointment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /fitness_appointments/1 or /fitness_appointments/1.json
  def destroy
    @fitness_appointment.destroy
    respond_to do |format|
      format.html { redirect_to fitness_appointments_url, notice: "Fitness appointment was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_fitness_appointment
      @fitness_appointment = FitnessAppointment.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def fitness_appointment_params
      params.require(:fitness_appointment).permit(:booking_type, :name, :relationship, :age, :gender, :marital_status, :date, :modile_number, :preference, :trainer, :reason_for_appointment, :created_by_id)
    end
end
