class RestaurantMenusController < ApplicationController
  before_action :set_restaurant_menu, only: %i[ show edit update destroy ]

  # GET /restaurant_menus or /restaurant_menus.json
  def index
    if params[:restaurant_id].present?
      @restaurant_menus = RestaurantMenu.where(restaurant_id: params[:restaurant_id]).ransack(params[:q]).result
    else
      @restaurant_menus = RestaurantMenu.ransack(params[:q]).result
    end
  end

  # GET /restaurant_menus/1 or /restaurant_menus/1.json
  def show
  end

  # GET /restaurant_menus/new
  def new
    @restaurant_menu = RestaurantMenu.new
  end

  # GET /restaurant_menus/1/edit
  def edit
  end

  # POST /restaurant_menus or /restaurant_menus.json

  def create
    @restaurant_menu = RestaurantMenu.new(restaurant_menu_params)
    if params[:restaurant_menu][:menu_image].present?
      @restaurant_menu.build_menu_image(
        image: params[:restaurant_menu][:menu_image],
        relation: "MenuImage",
        active: 1
      )
    end

    respond_to do |format|
      if @restaurant_menu.save
        format.html { redirect_to @restaurant_menu, notice: "Restaurant menu was successfully created." }
        format.json { render :show, status: :created, location: @restaurant_menu }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @restaurant_menu.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @restaurant_menu.update(restaurant_menu_params)
        if params[:restaurant_menu][:menu_image].present?
          @restaurant_menu.menu_image&.destroy!
          @restaurant_menu.create_menu_image!(
            image: params[:restaurant_menu][:menu_image],
            relation: "MenuImage",
            active: 1
          )
        end
        format.html { redirect_to @restaurant_menu, notice: "Restaurant menu was successfully updated." }
        format.json { render :show, status: :ok, location: @restaurant_menu }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @restaurant_menu.errors, status: :unprocessable_entity }
      end
    end
  end


  # POST /restaurant_menus/bulk_create
  def bulk_create
    menu_items = params[:menu_items] || []

    unless menu_items.any?
      return render json: { error: "Menu items are required" }, status: :unprocessable_entity
    end

    results = []
    errors = []

    menu_items.each do |item|
      menu = RestaurantMenu.new(
        name: item[:name],
        price: item[:price].to_f,
        category_name: item[:category_name],
        restaurant_id: item[:restaurant_id],
        active: item.fetch(:active, true)
      )

      if menu.save
        results << { id: menu.id, name: menu.name }
      else
        errors << { name: item[:name], errors: menu.errors.full_messages }
      end
    end

    respond_to do |format|
      if errors.empty?
        format.json { render json: { message: "#{results.count} menu item(s) created successfully", count: results.count, menu_items: results }, status: :created }
      else
        format.json { render json: { message: "Some items failed to create", count: results.count, successes: results.count, errors: errors }, status: :partial_content }
      end
    end
  end

  # DELETE /restaurant_menus/1 or /restaurant_menus/1.json
  def destroy
    @restaurant_menu.destroy
    respond_to do |format|
      format.html { redirect_to restaurant_menus_url, notice: "Restaurant menu was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_restaurant_menu
    @restaurant_menu = RestaurantMenu.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def restaurant_menu_params
    params.require(:restaurant_menu).permit(
      :name, :price, :category_name, :active, :sku, :restaurant_id,
      :description, :prep_time, :spice_level, :is_favorite
    )
  end
end
