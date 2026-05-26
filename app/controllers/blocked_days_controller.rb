class BlockedDaysController < ApplicationController
  before_action :set_blocked_day, only: %i[ show edit update destroy ]

  # GET /blocked_days or /blocked_days.json
  def index
    @blocked_days = BlockedDay.all
  end

  # GET /blocked_days/1 or /blocked_days/1.json
  def show
  end

  # GET /blocked_days/new
  def new
    @blocked_day = BlockedDay.new
  end

  # GET /blocked_days/1/edit
  def edit
  end

  # POST /blocked_days or /blocked_days.json
  def create
    @blocked_day = BlockedDay.new(blocked_day_params)

    respond_to do |format|
      if @blocked_day.save
        format.html { redirect_to @blocked_day, notice: "Blocked day was successfully created." }
        format.json { render :show, status: :created, location: @blocked_day }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @blocked_day.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /blocked_days/1 or /blocked_days/1.json
  def update
    respond_to do |format|
      if @blocked_day.update(blocked_day_params)
        format.html { redirect_to @blocked_day, notice: "Blocked day was successfully updated." }
        format.json { render :show, status: :ok, location: @blocked_day }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @blocked_day.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /blocked_days/1 or /blocked_days/1.json
  def destroy
    @blocked_day.destroy
    respond_to do |format|
      format.html { redirect_to blocked_days_url, notice: "Blocked day was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_blocked_day
      @blocked_day = BlockedDay.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def blocked_day_params
      params.require(:blocked_day).permit(:restaurant_id, :start_date, :start_date, :reason, :booking_allowed, :order_allowed)
    end
end
