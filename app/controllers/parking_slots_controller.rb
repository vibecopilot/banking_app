class ParkingSlotsController < ApplicationController
  include UserExt
  layout 'basic'
  before_action :authenticate_user!, if: :check_user
  before_action :api_user 
  before_action :set_user
  before_action :set_parking_slot, only: %i[ show edit update destroy ]

  # GET /parking_slots or /parking_slots.json
  def index
    @parking_slots = ParkingSlot.where(site_id: @user.current_site_id).ransack(params[:q]).result
  end

  # GET /parking_slots/1 or /parking_slots/1.json
  def show
  end

  # GET /parking_slots/new
  def new
    @parking_slot = ParkingSlot.new
  end

  # GET /parking_slots/1/edit
  def edit
  end

  # POST /parking_slots or /parking_slots.json
  def create
    @parking_slot = ParkingSlot.new(parking_slot_params.merge(site_id: @user.selected_site_id))
    respond_to do |format|
      if @parking_slot.save
        format.html { redirect_to @parking_slot, notice: "Parking slot was successfully created." }
        format.json { render :show, status: :created, location: @parking_slot }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @parking_slot.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /parking_slots/1 or /parking_slots/1.json
  def update
    respond_to do |format|
      if @parking_slot.update(parking_slot_params)
        format.html { redirect_to @parking_slot, notice: "Parking slot was successfully updated." }
        format.json { render :show, status: :ok, location: @parking_slot }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @parking_slot.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /parking_slots/1 or /parking_slots/1.json
  def destroy
    @parking_slot.destroy
    respond_to do |format|
      format.html { redirect_to parking_slots_url, notice: "Parking slot was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_parking_slot
      @parking_slot = ParkingSlot.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def parking_slot_params
      params.require(:parking_slot).permit(:site_id, :start_hr, :start_min, :end_hr, :end_min)
    end
end
