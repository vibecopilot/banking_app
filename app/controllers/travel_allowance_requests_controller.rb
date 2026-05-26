class TravelAllowanceRequestsController < ApplicationController
  before_action :set_travel_allowance_request, only: %i[ show edit update destroy ]

  # GET /travel_allowance_requests or /travel_allowance_requests.json
  def index
    @travel_allowance_requests = TravelAllowanceRequest.ransack(params[:q]).result
  end

  # GET /travel_allowance_requests/1 or /travel_allowance_requests/1.json
  def show
  end

  # GET /travel_allowance_requests/new
  def new
    @travel_allowance_request = TravelAllowanceRequest.new
  end

  # GET /travel_allowance_requests/1/edit
  def edit
  end

  # POST /travel_allowance_requests or /travel_allowance_requests.json
  def create
    @travel_allowance_request = TravelAllowanceRequest.new(travel_allowance_request_params)

    respond_to do |format|
      if @travel_allowance_request.save
        if params[:attachments].present? 
          params[:attachments].each do |doc|
            Attachfile.create(image: doc, relation: "TravelAllowanceRequest", relation_id: @travel_allowance_request.id, active: 1)
          end
        end
        format.html { redirect_to @travel_allowance_request, notice: "Travel allowance request was successfully created." }
        format.json { render :show, status: :created, location: @travel_allowance_request }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @travel_allowance_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /travel_allowance_requests/1 or /travel_allowance_requests/1.json
  def update
    respond_to do |format|
      if @travel_allowance_request.update(travel_allowance_request_params)
        format.html { redirect_to @travel_allowance_request, notice: "Travel allowance request was successfully updated." }
        format.json { render :show, status: :ok, location: @travel_allowance_request }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @travel_allowance_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /travel_allowance_requests/1 or /travel_allowance_requests/1.json
  def destroy
    @travel_allowance_request.destroy
    respond_to do |format|
      format.html { redirect_to travel_allowance_requests_url, notice: "Travel allowance request was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_travel_allowance_request
      @travel_allowance_request = TravelAllowanceRequest.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def travel_allowance_request_params
      params.require(:travel_allowance_request).permit(:employee_id, :employee_name, :expense_category, :date_of_expense, :amount_spent, :approval_status, :reimbursement_amount, :reimbursement_method, :manager_approval, :reimbursement_confirmation_email, :description_of_expense,:mobile_no)
    end
end
