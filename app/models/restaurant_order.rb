class RestaurantOrder < ApplicationRecord
  belongs_to :food_and_beverage, class_name: "FoodAndBeverage", foreign_key: :restaurant_id, optional: true
  belongs_to :created_by, class_name: "User", foreign_key: :created_by_id, optional: true
  belongs_to :table_booking, class_name: "TableBooking", foreign_key: :booking_id, optional: true
  belongs_to :restaurant_table, optional: true
  has_many :restaurant_order_items, class_name: "RestaurantOrderItem", foreign_key: :order_id, dependent: :destroy
  has_many :kitchen_order_tickets, foreign_key: :order_id, dependent: :destroy
  has_many :attachfiles, -> { where(relation: "OrderQR") }, foreign_key: :relation_id
  before_create :generate_confirm_token
  after_create :create_qr
  accepts_nested_attributes_for :restaurant_order_items, allow_destroy: true

  scope :by_restaurant, ->(id) { where(restaurant_id: id) if id.present? }
  scope :by_status, ->(s) { where(status: s) if s.present? }
  scope :by_order_type, ->(t) { where(order_type: t) if t.present? }
  scope :running, -> { where(status: "Running") }
  scope :completed, -> { where(status: "Completed") }
  scope :billed, -> { where(status: "Billed") }
  scope :today, -> { where(ondate: Date.today) }

  def mark_billed!(payment_mode: nil, paid_amount: nil)
    update!(
      status: "Billed",
      payment_mode: payment_mode.presence || self.payment_mode,
      paid_amount: paid_amount.presence || total_amount,
      billed_at: Time.current
    )
  end

  def mark_completed!
    update!(status: "Completed", completed_at: Time.current)
  end

  def generate_kot!(menu_item, quantity:, notes: nil, created_by: nil)
    kitchen_order_tickets.create!(
      restaurant_menu_id: menu_item.is_a?(Integer) ? menu_item : menu_item.id,
      item_name: menu_item.respond_to?(:name) ? menu_item.name : nil,
      quantity: quantity,
      notes: notes,
      created_by_id: created_by,
      sent_at: Time.current
    )
  end

  def total_ordered_quantity
    restaurant_order_items.sum(:quantity)
  end

  def subtotal
    restaurant_order_items.sum(:amount)
  end

  def qr_verify_url
    base = ENV['FRONTEND_URL'] || 'http://localhost:3000'
    "#{base}/fb/order-confirm/#{id}?token=#{confirm_token}"
  end

  def qr_image_url
    attachfiles.active.last&.image&.url
  end

  private

  def generate_confirm_token
    self.confirm_token = SecureRandom.urlsafe_base64(16)
  end

  def create_qr
    qrcode = RQRCode::QRCode.new(qr_verify_url)
    png = qrcode.as_png(
      resize_gte_to: false,
      resize_exactly_to: false,
      fill: 'white',
      color: 'black',
      size: 200,
      border_modules: 2,
      module_px_size: 6
    )
    path = Rails.root.join("tmp", "order_#{id}_qr.png")
    png.save(path)
    file = File.open(path, "rb")
    Attachfile.create(image: file, relation: "OrderQR", relation_id: id, active: true)
    file.close
    File.delete(path) rescue nil
  rescue => e
    Rails.logger.error("Failed to generate QR for order #{id}: #{e.message}")
  end
end
