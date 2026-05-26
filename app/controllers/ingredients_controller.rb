class IngredientsController < ApplicationController
  include UserExt
  before_action :api_user
  before_action :set_ingredient, only: %i[ show edit update destroy ]

  def index
    @ingredients = Ingredient.where(site_id: @user.current_site_id).order(created_at: :DESC)
    @ingredients = @ingredients.where(supplier_id: params[:supplier_id]) if params[:supplier_id].present?
    @ingredients = @ingredients.where(category: params[:category]) if params[:category].present?
    @ingredients = @ingredients.ransack(params[:q]).result
  end

  def show
  end

  def new
    @ingredient = Ingredient.new
  end

  def edit
  end

  def create
    @ingredient = Ingredient.new(ingredient_params)
    @ingredient.created_by_id = @user.id
    @ingredient.site_id = @user.current_site_id

    respond_to do |format|
      if @ingredient.save
        format.json { render :show, status: :created, location: @ingredient }
      else
        format.json { render json: @ingredient.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @ingredient.update(ingredient_params)
        format.json { render :show, status: :ok, location: @ingredient }
      else
        format.json { render json: @ingredient.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @ingredient.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private

  def set_ingredient
    @ingredient = Ingredient.find(params[:id])
  end

  def ingredient_params
    params.require(:ingredient).permit(:name, :sku, :category, :unit, :stock_quantity, :minimum_stock, :unit_price, :supplier_id)
  end
end
