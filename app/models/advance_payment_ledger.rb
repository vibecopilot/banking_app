class AdvancePaymentLedger < ApplicationRecord
  belongs_to :unit, class_name: 'Unit', foreign_key: 'unit_id', optional: true
  validates :unit_id, :months_paid, :amount, :paid_on, presence: true
  validates :months_paid, numericality: { only_integer: true, greater_than: 0 }
  validates :amount, numericality: { greater_than: 0 }
end
