class CamMonthlyExpense < ApplicationRecord
  self.table_name = 'monthly_expenses'

  validates :year, :month, :category, :amount, presence: true
  validates :month, inclusion: { in: 1..12 }
  validates :amount, numericality: { greater_than_or_equal_to: 0 }
end
