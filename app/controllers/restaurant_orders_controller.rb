class RestaurantOrdersController < ApplicationController
  include UserExt
  before_action :set_restaurant_order, only: %i[ show edit update destroy mark_billed mark_completed generate_kot kot_list mark_confirmed bill_pdf ]
  before_action :set_user

  def index
    @restaurant_orders = RestaurantOrder.includes(:restaurant_order_items, :kitchen_order_tickets)
    @restaurant_orders = @restaurant_orders.by_restaurant(params[:restaurant_id]) if params[:restaurant_id].present?
    unless @user.fb_admin? || params[:restaurant_id].present?
      restaurant_ids = FoodAndBeverage.where(created_by_id: @user.id).pluck(:id)
      @restaurant_orders = @restaurant_orders.where(restaurant_id: restaurant_ids)
    end
    @restaurant_orders = @restaurant_orders.by_status(params[:status]) if params[:status].present?
    @restaurant_orders = @restaurant_orders.by_order_type(params[:order_type]) if params[:order_type].present?
    @restaurant_orders = @restaurant_orders.where("ondate >= ?", params[:from_date]) if params[:from_date].present?
    @restaurant_orders = @restaurant_orders.where("ondate <= ?", params[:to_date]) if params[:to_date].present?
    @restaurant_orders = @restaurant_orders.order("created_at DESC")
    @restaurant_orders = @restaurant_orders.ransack(params[:q]).result
  end

  def show
  end

  def new
    @restaurant_order = RestaurantOrder.new
  end

  def edit
  end

  def create
    @restaurant_order = RestaurantOrder.new(restaurant_order_params)
    @restaurant_order.created_by_id = @user.id

    # Validate blocked days
    if @restaurant_order.ondate.present? && @restaurant_order.restaurant_id.present?
      restaurant = FoodAndBeverage.find_by(id: @restaurant_order.restaurant_id)
      if restaurant && restaurant.blocked_days_for_date?(@restaurant_order.ondate, type: :order)
        respond_to do |format|
          format.html { redirect_to new_restaurant_order_path, alert: "Orders are not allowed on this date." }
          format.json { render json: { error: "Orders are not allowed on this date." }, status: :unprocessable_entity }
        end
        return
      end
    end

    respond_to do |format|
      if @restaurant_order.save
        if params[:restaurant_order_items].present?
          create_order_items(params[:restaurant_order_items])
          apply_taxes_and_charges
        end
        format.html { redirect_to @restaurant_order, notice: "Restaurant order was successfully created." }
        format.json { render :show, status: :created, location: @restaurant_order }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @restaurant_order.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @restaurant_order.update(restaurant_order_params)
        if params[:restaurant_order_items].present?
          @restaurant_order.restaurant_order_items.destroy_all
          create_order_items(params[:restaurant_order_items])
          apply_taxes_and_charges
        end
        format.html { redirect_to @restaurant_order, notice: "Restaurant order was successfully updated." }
        format.json { render :show, status: :ok, location: @restaurant_order }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @restaurant_order.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @restaurant_order.destroy
    respond_to do |format|
      format.html { redirect_to restaurant_orders_url, notice: "Restaurant order was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def mark_billed
    if @restaurant_order.update(
        status: "Billed",
        payment_mode: params[:payment_mode].presence || @restaurant_order.payment_mode,
        paid_amount: params[:paid_amount].presence || @restaurant_order.total_amount,
        billed_at: Time.current,
        payment_status: "Paid"
      )
      render json: { success: true, order: @restaurant_order }
    else
      render json: { error: @restaurant_order.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # GET /restaurant_orders/:id/bill_pdf
  def bill_pdf
    @order = RestaurantOrder.includes(:restaurant_order_items, :food_and_beverage)
                            .find(params[:id])
    render pdf: "bill_#{@order.id}",
           disposition: 'inline',
           page_size: 'A4',
           margin: { top: 0, bottom: 0, left: 0, right: 0 },
           template: 'restaurant_orders/bill_pdf.html.erb',
           layout: 'layouts/pdf_layout.html.erb',
           formats: :pdf,
           encoding: 'utf8'
  end

  def mark_completed
    if @restaurant_order.update(status: "Completed", completed_at: Time.current)
      render json: { success: true, order: @restaurant_order }
    else
      render json: { error: @restaurant_order.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def generate_kot
    item_id = params[:restaurant_menu_id]
    quantity = params[:quantity] || 1
    notes = params[:notes]

    menu_item = RestaurantMenu.find_by(id: item_id) if item_id.present?

    begin
      ticket = @restaurant_order.generate_kot!(
        menu_item || item_id,
        quantity: quantity,
        notes: notes,
        created_by: @user.id
      )

      if params[:send_all].to_s == "true"
        @restaurant_order.restaurant_order_items.each do |oi|
          next if oi.restaurant_menu_id == item_id.to_i

          @restaurant_order.generate_kot!(
            oi.restaurant_menu_id || oi.id,
            quantity: oi.quantity,
            created_by: @user.id
          )
        end
      end

      render json: { success: true, ticket: ticket }
    rescue => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end

  def kot_list
    @tickets = @restaurant_order.kitchen_order_tickets.order(:created_at)
    render json: @tickets.map { |t|
      {
        id: t.id,
        item_name: t.item_name || t.restaurant_menu&.name || "Item ##{t.restaurant_menu_id}",
        quantity: t.quantity,
        status: t.status,
        notes: t.notes,
        sent_at: t.sent_at,
        accepted_at: t.accepted_at,
        preparing_at: t.preparing_at,
        ready_at: t.ready_at,
        served_at: t.served_at
      }
    }
  end

  def confirm_by_token
    @restaurant_order = RestaurantOrder.find_by!(confirm_token: params[:token])
    data = @restaurant_order.as_json(
      include: {
        restaurant_order_items: {
          methods: :restaurant_menu
        }
      },
      methods: [:subtotal]
    )
    data.merge!(
      'tax_amount' => @restaurant_order.tax_amount,
      'service_charge' => @restaurant_order.service_charge,
      'discount' => @restaurant_order.discount
    )
    render json: data
  end

  def mark_confirmed
    @restaurant_order.update!(confirmed_at: Time.current)
    render json: { success: true, order: @restaurant_order }
  end

  def table_status
    restaurant = FoodAndBeverage.find_by(id: params[:restaurant_id])

    return render(
      json: { error: "Restaurant not found" },
      status: :not_found
    ) unless restaurant
    today_orders = RestaurantOrder.where(restaurant_id: restaurant.id).where(ondate: Time.zone.today.all_day).where(status: %w[Running Billed]).select(
      :id,
      :status,
      :order_type,
      :customer_name,
      :customer_phone,
      :total_amount,
      :confirm_token,
      :restaurant_table_id,
      :table_name,
      :updated_at,
      :created_at
    )
    today_bookings = TableBooking.today.where(restaurant_id: restaurant.id).where(status: ["confirmed"]).where.not(restaurant_table_id: nil).includes(:restaurant_table)
    running_set = {}
    billed_set  = {}
    booking_set = {}

    # Orders Mapping
    today_orders.each do |order|
      next if order.restaurant_table_id.blank?
      key = order.restaurant_table_id
      case order.status
      when "Running"
        running_set[key] = order
      when "Billed"
        billed_set[key] = order
      end
    end

    # Bookings Mapping
    today_bookings.each do |booking|
      next if booking.restaurant_table_id.blank?
      key = booking.restaurant_table_id
      # Booking only if table has no active order
      unless running_set.key?(key) || billed_set.key?(key)
        booking_set[key] = booking
      end
    end
    tables = restaurant.restaurant_tables.includes(:restaurant_floor).map do |table|
      table_key = table.id
      order   = running_set[table_key] || billed_set[table_key]
      booking = booking_set[table_key]
      status =
      if order&.status == "Running"
        "running"
      elsif order&.status == "Billed"
        "billed"
      elsif booking.present?
        "reserved"
      else
        "available"
      end

      {
        id: table.id,
        name: table.name,
        capacity: table.capacity,
        floor_id: table.restaurant_floor_id,
        floor_name: table.restaurant_floor&.name || "General",
        status: status,
        status_source: 
        if order.present?
          "order"
        elsif booking.present?
          "booking"
        end,
        order_id: order&.id,
        restaurant_table_id: table.id,
        table_name: table.name,
        order_type: order&.order_type || "dine-in",
        customer_name: order&.customer_name || booking&.customer_name,
        customer_phone: order&.customer_phone || booking&.contact_number,
        total_amount: order&.total_amount,
        confirm_token: order&.confirm_token,
        last_used: order&.updated_at&.strftime("%d/%m/%Y %I:%M %p") || booking&.ontime&.strftime("%d/%m/%Y %I:%M %p")
      }
    end

    render json: {
      success: true,

      tables: tables,

      floors: restaurant.restaurant_floors.map do |floor|
        {
          id: floor.id,
          name: floor.name
        }
      end
    }
  end

  private

  def set_restaurant_order
    @restaurant_order = RestaurantOrder.includes(:restaurant_order_items, :kitchen_order_tickets).find(params[:id])
  end

  def restaurant_order_params
    params.require(:restaurant_order).permit(
      :restaurant_id, :ondate, :ontime, :user_id, :payment_status, :total_amount,
      :status, :created_by_id, :table_number, :booking_id, :order_type,
      :customer_name, :customer_phone, :customer_address,
      :restaurant_table_id, :table_name,
      :service_charge, :tax_amount, :discount, :paid_amount, :payment_mode,
      :delivery_charges, :convenience_fee
    )
  end

  def create_order_items(items)
    items = items.values if items.is_a?(ActionController::Parameters)
    items = Array(items)
    items.each do |item|
      RestaurantOrderItem.create!(
        order_id: @restaurant_order.id,
        restaurant_menu_id: item[:restaurant_menu_id] || item['restaurant_menu_id'],
        quantity: item[:quantity] || item['quantity'],
        amount: item[:amount] || item['amount'],
        rate: item[:rate] || item['rate']
      )
    end
  end

  def apply_taxes_and_charges
    restaurant = FoodAndBeverage.find_by(id: @restaurant_order.restaurant_id)
    return unless restaurant

    subtotal = @restaurant_order.subtotal.to_f

    tax_amount = case restaurant.tax_type.to_s.downcase
    when 'cgst_sgst'
      cgst = subtotal * (restaurant.cgst_rate.to_f / 100.0)
      sgst = subtotal * (restaurant.sgst_rate.to_f / 100.0)
      cgst + sgst
    when 'igst'
      subtotal * (restaurant.igst_rate.to_f / 100.0)
    when 'gst'
      subtotal * (restaurant.gst.to_f / 100.0)
    else
      0
    end

    service_charge = subtotal * (restaurant.service_charge_percent.to_f / 100.0)
    discount = subtotal * (restaurant.discount_percent.to_f / 100.0)
    delivery_charges = @restaurant_order.delivery_charges.to_f
    convenience_fee  = @restaurant_order.convenience_fee.to_f
    total = subtotal + service_charge + tax_amount - discount + delivery_charges + convenience_fee

    @restaurant_order.update_columns(
      tax_amount: tax_amount.round(2),
      service_charge: service_charge.round(2),
      discount: discount.round(2),
      total_amount: total.round(2)
    )
    @restaurant_order.reload
  end
end
