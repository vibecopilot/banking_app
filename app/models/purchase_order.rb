class PurchaseOrder < ApplicationRecord
  belongs_to :supplier, optional: true
  belongs_to :created_by, class_name: 'User', optional: true
  belongs_to :site, class_name: 'Site', foreign_key: :site_id, optional: true
  has_many :purchase_order_items, dependent: :destroy

  accepts_nested_attributes_for :purchase_order_items, allow_destroy: true

  before_create :generate_order_number
  before_save :calculate_total

  private

  def generate_order_number
    self.order_number ||= "PO-#{Time.current.strftime('%Y%m%d')}-#{SecureRandom.hex(4).upcase}"
  end

  def calculate_total
    self.total_amount = purchase_order_items.sum { |i| i.total_price.to_f }
  end
end
