class PurchaseOrderItem < ApplicationRecord
  belongs_to :purchase_order
  belongs_to :ingredient, optional: true

  before_save :calculate_total_price

  private

  def calculate_total_price
    self.total_price = (quantity.to_f * unit_price.to_f)
  end
end
