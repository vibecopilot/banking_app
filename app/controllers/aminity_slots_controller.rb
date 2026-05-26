class AminitySlotsController < ApplicationController
  before_action :set_aminity_slot, only: %i[ show edit update destroy ]

  # GET /aminity_slots or /aminity_slots.json
  def index
    @aminity_slots = AminitySlot.all
  end

  # GET /aminity_slots/1 or /aminity_slots/1.json
  def show
  end

  # GET /aminity_slots/new
  def new
    @aminity_slot = AminitySlot.new
  end

  # GET /aminity_slots/1/edit
  def edit
  end

  # POST /aminity_slots or /aminity_slots.json
  def create
    @aminity_slot = AminitySlot.new(aminity_slot_params)

    respond_to do |format|
      if @aminity_slot.save
        format.html { redirect_to @aminity_slot, notice: "Aminity slot was successfully created." }
        format.json { render :show, status: :created, location: @aminity_slot }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @aminity_slot.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /aminity_slots/1 or /aminity_slots/1.json
  def update
    respond_to do |format|
      if @aminity_slot.update(aminity_slot_params)
        format.html { redirect_to @aminity_slot, notice: "Aminity slot was successfully updated." }
        format.json { render :show, status: :ok, location: @aminity_slot }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @aminity_slot.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /aminity_slots/1 or /aminity_slots/1.json
  def destroy
    @aminity_slot.destroy
    respond_to do |format|
      format.html { redirect_to aminity_slots_url, notice: "Aminity slot was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_aminity_slot
      @aminity_slot = AminitySlot.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def aminity_slot_params
      params.require(:aminity_slot).permit(:aminity_id, :start_time, :end_time)
    end
end
