class TransportationAllowanceRequestsController < ApplicationController
  include UserExt
  layout 'basic'
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_transportation_allowance_request, only: %i[ show edit update destroy ]

  # GET /transportation_allowance_requests or /transportation_allowance_requests.json
  def index
    @transportation_allowance_requests = TransportationAllowanceRequest.all.ransack(params[:q]).result
    if params[:booking_status].present?
      @transportation_allowance_requests = @transportation_allowance_requests.where(booking_status: params[:booking_status]).ransack(params[:q]).result
    end
  end

  # GET /transportation_allowance_requests/1 or /transportation_allowance_requests/1.json
  def show
  end

  # GET /transportation_allowance_requests/new
  def new
    @transportation_allowance_request = TransportationAllowanceRequest.new
  end

  # GET /transportation_allowance_requests/1/edit
  def edit
  end

  # POST /transportation_allowance_requests or /transportation_allowance_requests.json
  def create
    @transportation_allowance_request = TransportationAllowanceRequest.new(transportation_allowance_request_params)

    respond_to do |format|
      if @transportation_allowance_request.save
        if params[:attachments].present? 
          params[:attachments].each do |doc|
            Attachfile.create(image: doc, relation: "TransportationAllowanceRequest", relation_id: @transportation_allowance_request.id, active: 1)
          end
        end
        format.html { redirect_to @transportation_allowance_request, notice: "Transportation allowance request was successfully created." }
        format.json { render :show, status: :created, location: @transportation_allowance_request }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @transportation_allowance_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /transportation_allowance_requests/1 or /transportation_allowance_requests/1.json
  def update
    respond_to do |format|
      if @transportation_allowance_request.update(transportation_allowance_request_params)
        if params[:attachments].present? 
          params[:attachments].each do |doc|
            Attachfile.create(image: doc, relation: "TransportationAllowanceRequest", relation_id: @transportation_allowance_request.id, active: 1)
          end
        end
        
        format.html { redirect_to @transportation_allowance_request, notice: "Transportation allowance request was successfully updated." }
        format.json { render :show, status: :ok, location: @transportation_allowance_request }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @transportation_allowance_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /transportation_allowance_requests/1 or /transportation_allowance_requests/1.json
  def destroy
    @transportation_allowance_request.destroy
    respond_to do |format|
      format.html { redirect_to transportation_allowance_requests_url, notice: "Transportation allowance request was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_transportation_allowance_request
      @transportation_allowance_request = TransportationAllowanceRequest.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def transportation_allowance_request_params
      params.require(:transportation_allowance_request).permit(:employee_name, :employee_id, :expense_category, :date_of_expense, :description_of_expense, :amount_spent, :approval_status, :reimbursement_amount, :reimbursement_method, :manager_approval, :reimbursement_confirmation_email,:mobile_no)
    end
end
