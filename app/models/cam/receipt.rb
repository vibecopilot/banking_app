class CamReceipt < ApplicationRecord
  self.table_name = 'receipts'

  validates :bill_type, :bill_id, :amount, :date, presence: true
  validates :amount, numericality: { greater_than: 0 }
end
