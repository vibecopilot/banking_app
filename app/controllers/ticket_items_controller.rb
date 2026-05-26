class TicketItemsController < ApplicationController
  include UserExt
  layout 'basic'
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_ticket_item, only: %i[ show edit update destroy ]

  # GET /ticket_items or /ticket_items.json
  def index
    if params[:q].present? && params[:q][:date_range].present?
     @date_range = params[:q][:date_range].split(" - ")
     params[:q][:created_at_lteq] = Date.strptime(@date_range[1], "%m/%d/%Y").strftime("%d/%m/%Y")
     params[:q][:created_at_gteq] = Date.strptime(@date_range[0], "%m/%d/%Y").strftime("%d/%m/%Y")
    end
    @per_page = params[:per_page]  || 10
    @complaints = Complaint.where(site_id: @user.current_site_id, territory_manager_id: @user.id).ransack(params[:q]).result.ransack(params[:q]).result.paginate(page: params[:page],per_page: @per_page).order("id DESC")
    if params[:items] == "true"
      @ticket_items = TicketItem.ransack(params[:q]).result
      render :index
    elsif params["format"] == "json"
      render "pms/manage/complaints/user_helpdesk"
    else
      render "pms/manage/complaints/index"
    end
  end

  # GET /ticket_items/1 or /ticket_items/1.json
  def show
  end

  def complete_ticket
    @complaint = Complaint.find(params[:complaint_log][:complaint_id])
    params[:logs].each do |log|
      nlog = ComplaintLog.create(complaint_id: @complaint.id, mode: log[:mode], changed_by: @user.id)
      log[:attachments].each do |doc|
        Attachfile.create(image: doc, relation: "ComplaintLog#{log[:mode]}", relation_id: nlog.id, active: 1)
      end
    end
    @approved_status = ComplaintStatus.find_or_create_by(society_id: @user.current_site_id, name: "Complete", active: 1)
    @complaint.update(issue_status: @approved_status.id)
    redirect_to params[:custom_redirect]
  end

  # GET /ticket_items/new
  def new
    @ticket_item = TicketItem.new
  end

  # GET /ticket_items/1/edit
  def edit
  end

  # POST /ticket_items or /ticket_items.json
  def create
    @ticket_item = TicketItem.new(ticket_item_params)

    respond_to do |format|
      if @ticket_item.save
        format.html { redirect_to @ticket_item, notice: "Ticket item was successfully created." }
        format.json { render :show, status: :created, location: @ticket_item }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @ticket_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /ticket_items/1 or /ticket_items/1.json
  def update
    respond_to do |format|
      if @ticket_item.update(ticket_item_params)
        format.html { redirect_to @ticket_item, notice: "Ticket item was successfully updated." }
        format.json { render :show, status: :ok, location: @ticket_item }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @ticket_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ticket_items/1 or /ticket_items/1.json
  def destroy
    @ticket_item.destroy
    respond_to do |format|
      format.html { redirect_to ticket_items_url, notice: "Ticket item was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ticket_item
      @ticket_item = TicketItem.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def ticket_item_params
      params.require(:ticket_item).permit(:ticket_id, :item_id, :rate, :item_count)
    end
end
