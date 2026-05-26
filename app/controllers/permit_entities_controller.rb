class PermitEntitiesController < ApplicationController
  include UserExt
  layout 'basic'
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_permit_entity, only: %i[ show edit update destroy ]

  # GET /permit_entities or /permit_entities.json
  def index
    @permit_entities = PermitEntity.where(site_id:@user.current_site_id).ransack(params[:q]).result
  end

  # GET /permit_entities/1 or /permit_entities/1.json
  def show
  end

  # GET /permit_entities/new
  def new
    @permit_entity = PermitEntity.new
  end

  # GET /permit_entities/1/edit
  def edit
  end

  # POST /permit_entities or /permit_entities.json
  def create
    @permit_entity = PermitEntity.new(permit_entity_params)

    respond_to do |format|
      if @permit_entity.save
        format.html { redirect_to @permit_entity, notice: "Permit entity was successfully created." }
        format.json { render :show, status: :created, location: @permit_entity }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @permit_entity.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /permit_entities/1 or /permit_entities/1.json
  def update
    respond_to do |format|
      if @permit_entity.update(permit_entity_params)
        format.html { redirect_to @permit_entity, notice: "Permit entity was successfully updated." }
        format.json { render :show, status: :ok, location: @permit_entity }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @permit_entity.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /permit_entities/1 or /permit_entities/1.json
  def destroy
    @permit_entity.destroy
    respond_to do |format|
      format.html { redirect_to permit_entities_url, notice: "Permit entity was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_permit_entity
      @permit_entity = PermitEntity.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def permit_entity_params
      params.require(:permit_entity).permit(:name, :permit_id, :active,:site_id)
    end
end
