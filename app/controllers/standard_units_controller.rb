class StandardUnitsController < ApplicationController
  before_action :set_standard_unit, only: %i[ show edit update destroy ]

  # GET /standard_units or /standard_units.json
  def index
    @standard_units = StandardUnit.all
  end

  # GET /standard_units/1 or /standard_units/1.json
  def show
  end

  # GET /standard_units/new
  def new
    @standard_unit = StandardUnit.new
  end

  # GET /standard_units/1/edit
  def edit
  end

  # POST /standard_units or /standard_units.json
  def create
    @standard_unit = StandardUnit.new(standard_unit_params)

    respond_to do |format|
      if @standard_unit.save
        format.html { redirect_to @standard_unit, notice: "Standard unit was successfully created." }
        format.json { render :show, status: :created, location: @standard_unit }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @standard_unit.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /standard_units/1 or /standard_units/1.json
  def update
    respond_to do |format|
      if @standard_unit.update(standard_unit_params)
        format.html { redirect_to @standard_unit, notice: "Standard unit was successfully updated." }
        format.json { render :show, status: :ok, location: @standard_unit }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @standard_unit.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /standard_units/1 or /standard_units/1.json
  def destroy
    @standard_unit.destroy
    respond_to do |format|
      format.html { redirect_to standard_units_url, notice: "Standard unit was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_standard_unit
      @standard_unit = StandardUnit.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def standard_unit_params
      params.require(:standard_unit).permit(:unit_name, :convention, :company_id)
    end
end
