class FoodAndBeveragesController < ApplicationController
  include UserExt
  layout 'basic'
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_food_and_beverage, only: %i[ show edit update destroy ]

  # GET /food_and_beverages or /food_and_beverages.json
  def index
    scope = FoodAndBeverage.includes(:gallery_images,
                                     :menu_images,
                                     :other_files,
                                     :menu_pdf,
                                     :cover_images,
                                     :attachfiles,
                                     :blocked_days,
                                     :restaurant_floors,
                                     :restaurant_tables,
                                     :restaurant_categories,
                                     :restaurant_cuisines,
                                     :restaurant_menus).where(site_id: @user.current_site_id)
    unless @user.fb_admin?
      scope = scope.where(created_by_id: @user.id)
    end
    @food_and_beverages = scope.order(created_at: :DESC)
  end

  # GET /food_and_beverages/1 or /food_and_beverages/1.json
  def show
    filtered_restaurant_schedule = @food_and_beverage.filtered_restaurant_schedule
  end

  # GET /food_and_beverages/new
  def new
    @food_and_beverage = FoodAndBeverage.new
    @food_and_beverage.initialize_restaurant_schedule
  end

  # GET /food_and_beverages/1/edit
  def edit
    @food_and_beverage.initialize_restaurant_schedule
  end

  # POST /food_and_beverages or /food_and_beverages.json
  def create
    normalize_food_and_beverage_params!
    @food_and_beverage = FoodAndBeverage.new(food_and_beverage_params)
    @food_and_beverage.created_by_id = @user.id
    @food_and_beverage.site_id = @user.current_site_id

    respond_to do |format|
      if @food_and_beverage.save
        reconcile_table_floors
        sync_blocked_days
        attach_food_and_beverage_files

        format.html { redirect_to @food_and_beverage, notice: "Food and beverage was successfully created." }
        format.json { render :show, status: :created, location: @food_and_beverage }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @food_and_beverage.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /food_and_beverages/1 or /food_and_beverages/1.json
  def update
    normalize_food_and_beverage_params!
    respond_to do |format|
      if @food_and_beverage.update(food_and_beverage_params)
        reconcile_table_floors
        sync_blocked_days
        attach_food_and_beverage_files

        format.html { redirect_to @food_and_beverage, notice: "Food and beverage was successfully updated." }
        format.json { render :show, status: :ok, location: @food_and_beverage }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @food_and_beverage.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /food_and_beverages/1 or /food_and_beverages/1.json
  def destroy
    @food_and_beverage.destroy
    respond_to do |format|
      format.html { redirect_to food_and_beverages_url, notice: "Food and beverage was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def export
    @food_and_beverages = FoodAndBeverage.all.order(created_at: :DESC)
    respond_to do |format|
      format.xlsx {
        response.headers['Content-Disposition'] = 'attachment; filename="food_and_beverage.xlsx"'
      }
    end
  end

  def sync_blocked_days
    params[:blocked_days].each do |blocked_day|
      if blocked_day[:id].present?
        existing = @food_and_beverage.blocked_days.find_by(id: blocked_day[:id])
        if blocked_day[:_destroy].to_s == '1'
          existing&.destroy
          next
        end

        next unless existing

        existing.update(
          start_date: blocked_day[:start_date],
          end_date: blocked_day[:end_date],
          order_allowed: ActiveModel::Type::Boolean.new.cast(blocked_day[:order_allowed]),
          booking_allowed: ActiveModel::Type::Boolean.new.cast(blocked_day[:booking_allowed]),
          reason: blocked_day[:reason]
        )
      else
        next if blocked_day[:start_date].blank? && blocked_day[:end_date].blank?

        @food_and_beverage.blocked_days.create(
          start_date: blocked_day[:start_date],
          end_date: blocked_day[:end_date],
          order_allowed: ActiveModel::Type::Boolean.new.cast(blocked_day[:order_allowed]),
          booking_allowed: ActiveModel::Type::Boolean.new.cast(blocked_day[:booking_allowed]),
          reason: blocked_day[:reason]
        )
      end
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_food_and_beverage
    @food_and_beverage = FoodAndBeverage.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def food_and_beverage_params
    params.require(:food_and_beverage).permit(
      :restaurant_name,
      :cost_for_two,
      :mobile_number,
      :alternate_mobile_number,
      :landline_number,
      :delivery_time,
      :start_time,
      :end_time,
      :serviceCharges,
      :order_not_allowed_text,
      :serves_alcohols,
      :wheelchair_accessible,
      :cash_on_delivery,
      :pure_veg,
      :address,
      :mon,
      :tue,
      :wed,
      :thu,
      :fri,
      :sat,
      :sun,
      :booking_allowed,
      :order_allowed,
      :terms_and_conditions,
      :last_booking_time,
      :disclaimer,
      :closing_message,
      :minimum_person,
      :maximum_person,
      :cancel_before,
      :gst,
      :delivery_charges,
    :convenience_fee,
      :minimum_order,
      :status,
      :break_end_time,
      :break_start_time,
      :restauranttype,
      :created_by_id,
      :table_booking_start_date,
      :table_number,
      :table_booking_end_date,
      :table_booking_start_time,
      :table_booking_end_time,
      :booking_capacity,
      :waiting_capacity,
      :booking_not_available_text,
      :site_id,
      :food_and_beverages_availability,
      # ---- F&B Setup new fields ---------------------------------------
      :email,
      :gst_number,
      :license_number,
      :fssai_number,
      :location_branch,
      :delivery_zone,
      :service_radius,
      :tax_type,
      :area_type,
      :cgst_rate,
      :sgst_rate,
      :igst_rate,
      :service_charge_percent,
      :discount_percent,
      :gpay_upi,
      :phonepe_upi,
      :paytm_upi,
      :razorpay_enabled,
      :razorpay_key,
      :razorpay_secret,
      restaurant_schedule: Date::DAYNAMES.map { |day| [day, [:selected, :start_time, :end_time, :booking_allowed, :order_allowed]] }.to_h,
      cuisines: [],
      payment_methods: [],
      restaurant_floors_attributes:     [:id, :name, :_destroy],
      restaurant_tables_attributes:     [:id, :name, :table_name, :capacity, :restaurant_floor_id, :restaurant_floor_client_id, :_destroy],
      restaurant_categories_attributes: [:id, :name, :custom, :_destroy],
      restaurant_cuisines_attributes:   [:id, :name, :custom, :_destroy],
      restaurant_menus_attributes:      [:id, :name, :price, :category_name, :category_id, :sub_category_id, :selected, :_destroy],
      blocked_days_attributes:          [:id, :start_date, :end_date, :reason, :booking_allowed, :order_allowed, :_destroy]
    )
  end

  def normalize_food_and_beverage_params!
    return unless params[:food_and_beverage].present?

    normalize_json_param!(:restaurant_schedule)
    normalize_array_param!(:cuisines)
    normalize_array_param!(:payment_methods)
    normalize_nested_collection!(:restaurant_floors_attributes)
    normalize_nested_collection!(:restaurant_tables_attributes)
    normalize_nested_collection!(:restaurant_categories_attributes)
    normalize_nested_collection!(:restaurant_cuisines_attributes)
    normalize_nested_collection!(:restaurant_menus_attributes)
    normalize_table_names!
    cache_and_strip_client_floor_ids!
  end

  def normalize_json_param!(key)
    value = params[:food_and_beverage][key]
    return unless value.is_a?(String)

    params[:food_and_beverage][key] = JSON.parse(value) rescue value
  end

  def normalize_array_param!(key)
    value = params[:food_and_beverage][key]
    parsed = value.is_a?(String) ? (JSON.parse(value) rescue value) : value
    params[:food_and_beverage][key] = Array(parsed).reject(&:blank?) if parsed.present?
  end

  def normalize_nested_collection!(key)
    value = params[:food_and_beverage][key]
    parsed = value.is_a?(String) ? (JSON.parse(value) rescue value) : value
    return unless parsed.is_a?(Array)

    params[:food_and_beverage][key] = parsed.each_with_index.each_with_object({}) do |(item, index), hash|
      hash[index.to_s] = item
    end
  end

  def normalize_table_names!
    tables = params.dig(:food_and_beverage, :restaurant_tables_attributes)
    return unless tables.respond_to?(:each)

    tables.each do |_index, table|
      table[:name] = table[:table_name] if table[:name].blank? && table[:table_name].present?
      table.delete(:table_name)
      table.delete('table_name')
    end
  end

  def cache_and_strip_client_floor_ids!
    @floor_client_ids = {}
    @table_floor_client_ids = {}

    floors = params.dig(:food_and_beverage, :restaurant_floors_attributes)
    if floors.respond_to?(:each)
      floors.each do |index, floor|
        client_id = floor.delete(:client_id) || floor.delete('client_id')
        @floor_client_ids[index.to_s] = client_id.to_s if client_id.present?
      end
    end

    tables = params.dig(:food_and_beverage, :restaurant_tables_attributes)
    return unless tables.respond_to?(:each)

    tables.each do |index, table|
      client_id = table.delete(:restaurant_floor_client_id) || table.delete('restaurant_floor_client_id')
      @table_floor_client_ids[index.to_s] = client_id.to_s if client_id.present?
    end
  end

  def attach_food_and_beverage_files
    attach_files(:attachfiles, 'FoodAndBeveragesDocument')
    attach_files(:cover_images, 'FoodAndBeveragesCoverImage')
    attach_files(:menu_pdf, 'FoodAndBeveragesMenuPdf')
    attach_files(:other_files, 'FoodAndBeveragesOtherFile')
    attach_files(:menu_images, 'FoodAndBeveragesMenuImage')
    attach_files(:gallery_images, 'FoodAndBeveragesGalleryImage')
    attach_files(:logo, 'FBLogo', single: true)
  end

  def attach_files(param_key, relation, single: false)
    files = single ? [params[param_key]] : Array(params[param_key])
    files.compact.each do |file|
      next if file.to_s == "[object Object]"

      Attachfile.create(image: file, relation: relation, relation_id: @food_and_beverage.id, active: 1)
    end
  end

  def sync_blocked_days
    blocked_days = params[:blocked_days] || params.dig(:food_and_beverage, :blocked_days_attributes)
    blocked_days = JSON.parse(blocked_days) rescue blocked_days if blocked_days.is_a?(String)
    return unless blocked_days.present?

    collection = blocked_days.respond_to?(:values) ? blocked_days.values : Array(blocked_days)
    collection.each do |block_day|
      attributes = block_day.respond_to?(:to_unsafe_h) ? block_day.to_unsafe_h : block_day.to_h
      next if attributes['start_date'].blank? && attributes[:start_date].blank?

      if truthy?(attributes['_destroy'] || attributes[:_destroy]) && (attributes['id'] || attributes[:id]).present?
        @food_and_beverage.blocked_days.find_by(id: attributes['id'] || attributes[:id])&.destroy
        next
      end

      blocked_day = attributes['id'].present? || attributes[:id].present? ?
        @food_and_beverage.blocked_days.find_or_initialize_by(id: attributes['id'] || attributes[:id]) :
        @food_and_beverage.blocked_days.build

      blocked_day.assign_attributes(
        start_date: attributes['start_date'] || attributes[:start_date],
        end_date: attributes['end_date'] || attributes[:end_date],
        reason: attributes['reason'] || attributes[:reason],
        order_allowed: attributes['order_allowed'] || attributes[:order_allowed],
        booking_allowed: attributes['booking_allowed'] || attributes[:booking_allowed]
      )
      blocked_day.save!
    end
  end

  def reconcile_table_floors
    floor_params = params.dig(:food_and_beverage, :restaurant_floors_attributes)
    table_params = params.dig(:food_and_beverage, :restaurant_tables_attributes)
    return unless floor_params.respond_to?(:each) && table_params.respond_to?(:each)

    floors_by_client_id = {}
    floor_params.each do |_index, floor_attrs|
      client_id = @floor_client_ids[_index.to_s]
      name = floor_attrs[:name] || floor_attrs['name']
      next if client_id.blank? || name.blank?

      floor = @food_and_beverage.restaurant_floors.find_by(name: name)
      floors_by_client_id[client_id.to_s] = floor if floor.present?
    end

    table_params.each do |_index, table_attrs|
      client_id = @table_floor_client_ids[_index.to_s]
      next if client_id.blank? || floors_by_client_id[client_id.to_s].blank?

      table_id = table_attrs[:id] || table_attrs['id']
      table_name = table_attrs[:name] || table_attrs['name'] || table_attrs[:table_name] || table_attrs['table_name']
      table = table_id.present? ? @food_and_beverage.restaurant_tables.find_by(id: table_id) : @food_and_beverage.restaurant_tables.where(name: table_name).order(created_at: :desc).first
      table&.update_column(:restaurant_floor_id, floors_by_client_id[client_id.to_s].id)
    end
  end

  def truthy?(value)
    ActiveModel::Type::Boolean.new.cast(value)
  end
end
