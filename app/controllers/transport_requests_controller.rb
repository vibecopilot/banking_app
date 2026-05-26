class TransportRequestsController < ApplicationController
  include UserExt
  layout 'basic'
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_transport_request, only: %i[ show edit update destroy ]

  # GET /transport_requests or /transport_requests.json
  def index
    @transport_requests = TransportRequest.ransack(params[:q]).result
    if params[:booking_status].present?
      @transport_requests = @transport_requests.where(booking_status: params[:booking_status])
    end
  end

  # GET /transport_requests/1 or /transport_requests/1.json
  def show
  end

  # GET /transport_requests/new
  def new
    @transport_request = TransportRequest.new
  end

  # GET /transport_requests/1/edit
  def edit
  end

  # POST /transport_requests or /transport_requests.json
  def create
    @transport_request = TransportRequest.new(transport_request_params)

    respond_to do |format|
      if @transport_request.save
        format.html { redirect_to @transport_request, notice: "Transport request was successfully created." }
        format.json { render :show, status: :created, location: @transport_request }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @transport_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /transport_requests/1 or /transport_requests/1.json
  def update
    respond_to do |format|
      if @transport_request.update(transport_request_params)
        format.html { redirect_to @transport_request, notice: "Transport request was successfully updated." }
        format.json { render :show, status: :ok, location: @transport_request }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @transport_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /transport_requests/1 or /transport_requests/1.json
  def destroy
    @transport_request.destroy
    respond_to do |format|
      format.html { redirect_to transport_requests_url, notice: "Transport request was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_transport_request
      @transport_request = TransportRequest.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def transport_request_params
      params.require(:transport_request).permit(:mobile_no, :employee_name, :employee_id, :pickup_location, :date_and_time, :special_requirements, :driver_contact_information, :vehicle_details, :booking_confirmation_number, :booking_status, :manager_approval, :booking_confirmation_email,:start_date,:end_date,:drop_off_location)
    end
end
