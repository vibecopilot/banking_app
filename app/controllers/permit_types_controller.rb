class PermitTypesController < ApplicationController
  before_action :set_permit_type, only: %i[ show edit update destroy ]

  # GET /permit_types or /permit_types.json
  def index
    @permit_types = PermitType.all
  end

  # GET /permit_types/1 or /permit_types/1.json
  def show
  end

  # GET /permit_types/new
  def new
    @permit_type = PermitType.new
  end

  # GET /permit_types/1/edit
  def edit
  end

  # POST /permit_types or /permit_types.json
  def create
    @permit_type = PermitType.new(permit_type_params)

    respond_to do |format|
      if @permit_type.save
        format.html { redirect_to @permit_type, notice: "Permit type was successfully created." }
        format.json { render :show, status: :created, location: @permit_type }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @permit_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /permit_types/1 or /permit_types/1.json
  def update
    respond_to do |format|
      if @permit_type.update(permit_type_params)
        format.html { redirect_to @permit_type, notice: "Permit type was successfully updated." }
        format.json { render :show, status: :ok, location: @permit_type }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @permit_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /permit_types/1 or /permit_types/1.json
  def destroy
    @permit_type.destroy
    respond_to do |format|
      format.html { redirect_to permit_types_url, notice: "Permit type was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_permit_type
      @permit_type = PermitType.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def permit_type_params
      params.require(:permit_type).permit(:name, :site_id)
    end
end
