class PermitSafetyEquipmentsController < ApplicationController
  before_action :set_permit_safety_equipment, only: %i[ show edit update destroy ]

  # GET /permit_safety_equipments or /permit_safety_equipments.json
  def index
    @permit_safety_equipments = PermitSafetyEquipment.all
  end

  # GET /permit_safety_equipments/1 or /permit_safety_equipments/1.json
  def show
  end

  # GET /permit_safety_equipments/new
  def new
    @permit_safety_equipment = PermitSafetyEquipment.new
  end

  # GET /permit_safety_equipments/1/edit
  def edit
  end

  # POST /permit_safety_equipments or /permit_safety_equipments.json
  def create
    @permit_safety_equipment = PermitSafetyEquipment.new(permit_safety_equipment_params)

    respond_to do |format|
      if @permit_safety_equipment.save
        format.html { redirect_to @permit_safety_equipment, notice: "Permit safety equipment was successfully created." }
        format.json { render :show, status: :created, location: @permit_safety_equipment }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @permit_safety_equipment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /permit_safety_equipments/1 or /permit_safety_equipments/1.json
  def update
    respond_to do |format|
      if @permit_safety_equipment.update(permit_safety_equipment_params)
        format.html { redirect_to @permit_safety_equipment, notice: "Permit safety equipment was successfully updated." }
        format.json { render :show, status: :ok, location: @permit_safety_equipment }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @permit_safety_equipment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /permit_safety_equipments/1 or /permit_safety_equipments/1.json
  def destroy
    @permit_safety_equipment.destroy
    respond_to do |format|
      format.html { redirect_to permit_safety_equipments_url, notice: "Permit safety equipment was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_permit_safety_equipment
      @permit_safety_equipment = PermitSafetyEquipment.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def permit_safety_equipment_params
      params.require(:permit_safety_equipment).permit(:safety_equipment_name, :permit_type_id, :activity_id, :sub_activity_id, :hazard_category_id, :permit_risk_id)
    end
end
