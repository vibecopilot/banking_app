class CabAndBusRequestsController < ApplicationController
  include UserExt
  layout 'basic'
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_cab_and_bus_request, only: %i[ show edit update destroy ]

  # GET /cab_and_bus_requests or /cab_and_bus_requests.json
  def index
    @cab_and_bus_requests = CabAndBusRequest.ransack(params[:q]).result
    if params[:booking_status].present?
      @cab_and_bus_requests = @cab_and_bus_requests.where(booking_status: params[:booking_status])
    end
  end

  # GET /cab_and_bus_requests/1 or /cab_and_bus_requests/1.json
  def show
  end

  # GET /cab_and_bus_requests/new
  def new
    @cab_and_bus_request = CabAndBusRequest.new
  end

  # GET /cab_and_bus_requests/1/edit
  def edit
  end

  # POST /cab_and_bus_requests or /cab_and_bus_requests.json
  def create
    @cab_and_bus_request = CabAndBusRequest.new(cab_and_bus_request_params)

    respond_to do |format|
      if @cab_and_bus_request.save
        format.html { redirect_to @cab_and_bus_request, notice: "Cab and bus request was successfully created." }
        format.json { render :show, status: :created, location: @cab_and_bus_request }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @cab_and_bus_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /cab_and_bus_requests/1 or /cab_and_bus_requests/1.json
  def update
    respond_to do |format|
      if @cab_and_bus_request.update(cab_and_bus_request_params)
        format.html { redirect_to @cab_and_bus_request, notice: "Cab and bus request was successfully updated." }
        format.json { render :show, status: :ok, location: @cab_and_bus_request }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @cab_and_bus_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cab_and_bus_requests/1 or /cab_and_bus_requests/1.json
  def destroy
    @cab_and_bus_request.destroy
    respond_to do |format|
      format.html { redirect_to cab_and_bus_requests_url, notice: "Cab and bus request was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_cab_and_bus_request
      @cab_and_bus_request = CabAndBusRequest.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def cab_and_bus_request_params
      params.require(:cab_and_bus_request).permit(:employee_name, :employee_id, :pickup_location, :drop_off_location, :date_and_time, :number_of_passengers, :transportation_type, :special_requirements, :driver_contact_information, :vehicle_details, :booking_confirmation_number, :booking_status, :manager_approval, :booking_confirmation_email,:mobile_no)
    end
end
