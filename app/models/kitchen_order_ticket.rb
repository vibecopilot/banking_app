class KitchenOrderTicket < ApplicationRecord
  belongs_to :restaurant_order, class_name: "RestaurantOrder", foreign_key: :order_id
  belongs_to :restaurant_menu, optional: true

  validates :quantity, numericality: { greater_than: 0 }

  scope :pending, -> { where(status: "pending") }
  scope :accepted, -> { where(status: "accepted") }
  scope :preparing, -> { where(status: "preparing") }
  scope :ready, -> { where(status: "ready") }
  scope :served, -> { where(status: "served") }

  def accept!
    update!(status: "accepted", accepted_at: Time.current)
  end

  def start_preparing!
    update!(status: "preparing", preparing_at: Time.current)
  end

  def mark_ready!
    update!(status: "ready", ready_at: Time.current)
  end

  def mark_served!
    update!(status: "served", served_at: Time.current)
  end
end
