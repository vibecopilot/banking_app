class KitchenOrderTicketsController < ApplicationController
  include UserExt
  before_action :set_user
  before_action :set_ticket, only: %i[show update accept start_preparing mark_ready mark_served]

  def index
    @tickets = KitchenOrderTicket.includes(:restaurant_order).order(created_at: :desc)
    @tickets = @tickets.where(order_id: params[:order_id]) if params[:order_id].present?
    @tickets = @tickets.where(status: params[:status]) if params[:status].present?
    if params[:restaurant_id].present?
      @tickets = @tickets.joins(:restaurant_order).where(restaurant_orders: { restaurant_id: params[:restaurant_id] })
    end
    unless @user.fb_admin? || params[:restaurant_id].present?
      restaurant_ids = FoodAndBeverage.where(created_by_id: @user.id).pluck(:id)
      @tickets = @tickets.joins(:restaurant_order).where(restaurant_orders: { restaurant_id: restaurant_ids })
    end
    render json: @tickets.map { |t| ticket_json(t) }
  end

  def show
    render json: ticket_json(@ticket)
  end

  def create
    @order = RestaurantOrder.find(params[:order_id])
    @ticket = @order.kitchen_order_tickets.build(ticket_params)
    @ticket.created_by_id = @user.id
    @ticket.sent_at = Time.current

    if params[:restaurant_menu_id].present?
      menu = RestaurantMenu.find_by(id: params[:restaurant_menu_id])
      @ticket.restaurant_menu_id = menu&.id
      @ticket.item_name = menu&.name
    end

    if params[:bulk].to_s == "true"
      @order.restaurant_order_items.each do |oi|
        @order.kitchen_order_tickets.create!(
          restaurant_menu_id: oi.restaurant_menu_id,
          item_name: oi.restaurant_menu&.name || "Item ##{oi.id}",
          quantity: oi.quantity,
          created_by_id: @user.id,
          sent_at: Time.current
        )
      end
      render json: { success: true, message: "All items sent to kitchen" }
    elsif @ticket.save
      render json: { success: true, ticket: ticket_json(@ticket) }
    else
      render json: { error: @ticket.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @ticket.update(ticket_params)
      render json: { success: true, ticket: ticket_json(@ticket) }
    else
      render json: { error: @ticket.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def accept
    @ticket.accept!
    render json: { success: true, ticket: ticket_json(@ticket) }
  end

  def start_preparing
    @ticket.start_preparing!
    render json: { success: true, ticket: ticket_json(@ticket) }
  end

  def mark_ready
    @ticket.mark_ready!
    render json: { success: true, ticket: ticket_json(@ticket) }
  end

  def mark_served
    @ticket.mark_served!
    render json: { success: true, ticket: ticket_json(@ticket) }
  end

  private

  def set_ticket
    @ticket = KitchenOrderTicket.find(params[:id])
  end

  def ticket_params
    params.permit(:order_id, :restaurant_menu_id, :item_name, :quantity, :notes, :status)
  end

  def ticket_json(ticket)
    order = ticket.restaurant_order
    {
      id: ticket.id,
      order_id: ticket.order_id,
      restaurant_menu_id: ticket.restaurant_menu_id,
      item_name: ticket.item_name || ticket.restaurant_menu&.name,
      quantity: ticket.quantity,
      status: ticket.status,
      notes: ticket.notes,
      sent_at: ticket.sent_at,
      accepted_at: ticket.accepted_at,
      preparing_at: ticket.preparing_at,
      ready_at: ticket.ready_at,
      served_at: ticket.served_at,
      created_at: ticket.created_at,
      table_name: order&.table_name || order&.table_number,
      customer_name: order&.customer_name,
      order_type: order&.order_type
    }
  end
end
