class FitoutSubcategoriesController < ApplicationController

	before_action :set_fitout_subcategory, only: [:show, :edit, :update, :destroy]

  def index
    @fitout_subcategories = FitoutSubcategory.order(created_at: :desc)
    render json: @fitout_subcategories
  end

  def show
  	@fitout_subcategories = FitoutSubcategory.find(params[:id])
    render json: @fitout_subcategories
  end

  def new
    @fitout_subcategory = FitoutSubcategory.new
  end

  def create
  if params[:name_tags].present?
    created_records = []
    params[:name_tags].each do |name_tag|
      subcategory = FitoutSubcategory.new(fitout_subcategory_params.merge(name: name_tag))
      
      if subcategory.save
        created_records << subcategory
      else
        render :new, status: :unprocessable_entity and return
      end
    end

    flash[:notice] = "Fitout Subcategories were successfully created."
    redirect_to fitout_subcategories_path
  else
    @fitout_subcategory = FitoutSubcategory.new(fitout_subcategory_params)
    
    if @fitout_subcategory.save
      redirect_to @fitout_subcategory, notice: "Fitout Subcategory was successfully created."
    else
      render :new
    end
  end
end


  def edit
  end

  def update
    if @fitout_subcategory.update(fitout_subcategory_params)
      redirect_to @fitout_subcategory, notice: "Fitout Subcategory was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    @fitout_subcategory.destroy
    redirect_to fitout_subcategories_url, notice: "Fitout Subcategory was successfully deleted."
  end

  private

  def set_fitout_subcategory
    @fitout_subcategory = FitoutSubcategory.find(params[:id])
  end

  def fitout_subcategory_params
    params.require(:fitout_subcategory).permit(:fitout_category_name, :fitout_category_id, :name, :position, :active, :issue_type_id, :bhk_prices, :fitout_text)
  end
end
