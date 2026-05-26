class Ingredient < ApplicationRecord
  belongs_to :supplier, optional: true
  belongs_to :created_by, class_name: 'User', optional: true
  belongs_to :site, class_name: 'Site', foreign_key: :site_id, optional: true
  has_many :purchase_order_items, dependent: :nullify

  def low_stock?
    stock_quantity.present? && minimum_stock.present? && stock_quantity <= minimum_stock
  end

  def out_of_stock?
    stock_quantity.blank? || stock_quantity <= 0
  end
end
