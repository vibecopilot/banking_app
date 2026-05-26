class TicketLogsController < ApplicationController
  before_action :set_ticket_log, only: %i[ show edit update destroy ]

  # GET /ticket_logs or /ticket_logs.json
  def index
    @ticket_logs = TicketLog.all
  end

  # GET /ticket_logs/1 or /ticket_logs/1.json
  def show
  end

  # GET /ticket_logs/new
  def new
    @ticket_log = TicketLog.new
  end

  # GET /ticket_logs/1/edit
  def edit
  end

  # POST /ticket_logs or /ticket_logs.json
  def create
    @ticket_log = TicketLog.new(ticket_log_params)

    respond_to do |format|
      if @ticket_log.save
        format.html { redirect_to @ticket_log, notice: "Ticket log was successfully created." }
        format.json { render :show, status: :created, location: @ticket_log }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @ticket_log.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /ticket_logs/1 or /ticket_logs/1.json
  def update
    respond_to do |format|
      if @ticket_log.update(ticket_log_params)
        format.html { redirect_to @ticket_log, notice: "Ticket log was successfully updated." }
        format.json { render :show, status: :ok, location: @ticket_log }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @ticket_log.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ticket_logs/1 or /ticket_logs/1.json
  def destroy
    @ticket_log.destroy
    respond_to do |format|
      format.html { redirect_to ticket_logs_url, notice: "Ticket log was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ticket_log
      @ticket_log = TicketLog.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def ticket_log_params
      params.require(:ticket_log).permit(:ticket_id, :created_by_id, :status, :log_type, :remarks)
    end
end
