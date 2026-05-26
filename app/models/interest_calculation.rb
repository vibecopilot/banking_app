class InterestCalculation < ApplicationRecord
  belongs_to :site
  belongs_to :unit
  belongs_to :cam_bill
  
  validates :principal_amount, :interest_rate, :interest_amount, presence: true
  validates :principal_amount, :interest_amount, numericality: { greater_than_or_equal_to: 0 }
  validates :interest_rate, numericality: { greater_than: 0 }
  
  scope :calculated, -> { where(status: 'calculated') }
  scope :applied, -> { where(status: 'applied') }
  scope :for_date_range, ->(from_date, to_date) { where(calculation_date: from_date..to_date) }
end
