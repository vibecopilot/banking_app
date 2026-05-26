class AdditionalPassengersController < ApplicationController
  before_action :set_additional_passenger, only: %i[ show edit update destroy ]

  # GET /additional_passengers or /additional_passengers.json
  def index
    @additional_passengers = AdditionalPassenger.all
  end

  # GET /additional_passengers/1 or /additional_passengers/1.json
  def show
  end

  # GET /additional_passengers/new
  def new
    @additional_passenger = AdditionalPassenger.new
  end

  # GET /additional_passengers/1/edit
  def edit
  end

  # POST /additional_passengers or /additional_passengers.json
  def create
    @additional_passenger = AdditionalPassenger.new(additional_passenger_params)

    respond_to do |format|
      if @additional_passenger.save
        format.html { redirect_to @additional_passenger, notice: "Additional passenger was successfully created." }
        format.json { render :show, status: :created, location: @additional_passenger }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @additional_passenger.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /additional_passengers/1 or /additional_passengers/1.json
  def update
    respond_to do |format|
      if @additional_passenger.update(additional_passenger_params)
        format.html { redirect_to @additional_passenger, notice: "Additional passenger was successfully updated." }
        format.json { render :show, status: :ok, location: @additional_passenger }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @additional_passenger.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /additional_passengers/1 or /additional_passengers/1.json
  def destroy
    @additional_passenger.destroy
    respond_to do |format|
      format.html { redirect_to additional_passengers_url, notice: "Additional passenger was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_additional_passenger
      @additional_passenger = AdditionalPassenger.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def additional_passenger_params
      params.require(:additional_passenger).permit(:name, :gender, :flight_request_id)
    end
end
