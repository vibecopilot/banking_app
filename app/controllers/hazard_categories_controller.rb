class HazardCategoriesController < ApplicationController
   include UserExt
  layout 'basic'
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_hazard_category, only: %i[ show edit update destroy ]

  # GET /hazard_categories or /hazard_categories.json
  def index
    @hazard_categories = HazardCategory.all
  end

  # GET /hazard_categories/1 or /hazard_categories/1.json
  def show
  end

  # GET /hazard_categories/new
  def new
    @hazard_category = HazardCategory.new
  end

  # GET /hazard_categories/1/edit
  def edit
  end

  # POST /hazard_categories or /hazard_categories.json
  def create
    @hazard_category = HazardCategory.new(hazard_category_params)

    respond_to do |format|
      if @hazard_category.save
        format.html { redirect_to @hazard_category, notice: "Hazard category was successfully created." }
        format.json { render :show, status: :created, location: @hazard_category }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @hazard_category.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /hazard_categories/1 or /hazard_categories/1.json
  def update
    respond_to do |format|
      if @hazard_category.update(hazard_category_params)
        format.html { redirect_to @hazard_category, notice: "Hazard category was successfully updated." }
        format.json { render :show, status: :ok, location: @hazard_category }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @hazard_category.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /hazard_categories/1 or /hazard_categories/1.json
  def destroy
    @hazard_category.destroy
    respond_to do |format|
      format.html { redirect_to hazard_categories_url, notice: "Hazard category was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_hazard_category
      @hazard_category = HazardCategory.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def hazard_category_params
      params.require(:hazard_category).permit(:name, :description, :sub_activity_id, :activity_id, :site_id)
    end
end
