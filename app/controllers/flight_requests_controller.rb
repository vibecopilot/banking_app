class FlightRequestsController < ApplicationController
  include UserExt
  layout 'basic'
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_flight_request, only: %i[ show edit update destroy ]

  # GET /flight_requests or /flight_requests.json
  def index
    @flight_requests = FlightRequest.ransack(params[:q]).result
    if params[:booking_status].present?
      @flight_requests = @flight_requests.where(booking_status: params[:booking_status])
    end
  end

  # GET /flight_requests/1 or /flight_requests/1.json
  def show
  end

  # GET /flight_requests/new
  def new
    @flight_request = FlightRequest.new
  end

  # GET /flight_requests/1/edit
  def edit
  end

  # POST /flight_requests or /flight_requests.json
  def create
    @flight_request = FlightRequest.new(flight_request_params)

    respond_to do |format|
      if @flight_request.save
        #  if params[:additional_passengers].present?
        #   params[:additional_passengers].each do |passenger_params|
        #     AdditionalPassenger.create(
        #       flight_request_id: @flight_request.id,
        #       name: passenger_params[:name],
        #       gender: passenger_params[:gender]
        #     )
        #   end
        # end
        format.html { redirect_to @flight_request, notice: "Flight request was successfully created." }
        format.json { render :show, status: :created, location: @flight_request }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @flight_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /flight_requests/1 or /flight_requests/1.json
  def update
    respond_to do |format|
      if @flight_request.update(flight_request_params)
        format.html { redirect_to @flight_request, notice: "Flight request was successfully updated." }
        format.json { render :show, status: :ok, location: @flight_request }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @flight_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /flight_requests/1 or /flight_requests/1.json
  def destroy
    @flight_request.destroy
    respond_to do |format|
      format.html { redirect_to flight_requests_url, notice: "Flight request was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_flight_request
      @flight_request = FlightRequest.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def flight_request_params
      params.require(:flight_request).permit(:employee_name, :employee_id, :departure_city, :arrival_city, :departure_date, :return_date, :preferred_airlines, :flight_class, :passenger_name, :passport_information, :ticket_confirmation_number, :booking_status, :manager_approval, :booking_confirmation_email,:mobile_no,:email,
        additional_passengers_attributes: [:id, :name, :gender,:class_type, :_destroy])
    end
end
