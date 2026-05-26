class IncomeEntry < ApplicationRecord
  belongs_to :site
  belongs_to :user, optional: true
  belongs_to :unit, optional: true
  belongs_to :journal_entry, optional: true
  belongs_to :source, polymorphic: true, optional: true
  
  # Validations
  validates :site_id, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :received_date, presence: true
  validates :payment_mode, presence: true
  validates :status, presence: true, inclusion: { in: %w[received pending cancelled] }
  
  # Scopes
  scope :received, -> { where(status: 'received') }
  scope :pending, -> { where(status: 'pending') }
  scope :for_date_range, ->(from_date, to_date) { where(received_date: from_date..to_date) }
  scope :from_cam_bills, -> { where(source_type: 'CamBill') }
  scope :from_invoices, -> { where(source_type: 'AccountingInvoice') }

  # Use income_month/income_year when available, fallback to received_date
  scope :by_income_period, ->(year, start_month, end_month = nil) {
    end_month ||= start_month
    period_start = Date.new(year, start_month, 1)
    period_end   = Date.new(year, end_month, -1)
    where(
      "(income_entries.income_month IS NOT NULL AND income_entries.income_year IS NOT NULL " \
      "AND income_entries.income_year = ? AND income_entries.income_month BETWEEN ? AND ?) " \
      "OR ((income_entries.income_month IS NULL OR income_entries.income_year IS NULL) " \
      "AND income_entries.received_date BETWEEN ? AND ?)",
      year, start_month, end_month, period_start, period_end
    )
  }

  scope :by_income_date_range, ->(from_date, to_date) {
    where(
      "(income_entries.income_month IS NOT NULL AND income_entries.income_year IS NOT NULL " \
      "AND ((income_entries.income_year > ? OR (income_entries.income_year = ? AND income_entries.income_month >= ?)) " \
      "AND  (income_entries.income_year < ? OR (income_entries.income_year = ? AND income_entries.income_month <= ?)))) " \
      "OR ((income_entries.income_month IS NULL OR income_entries.income_year IS NULL) " \
      "AND income_entries.received_date BETWEEN ? AND ?)",
      from_date.year, from_date.year, from_date.month,
      to_date.year, to_date.year, to_date.month,
      from_date, to_date
    )
  }

  # Auto-set income_month/income_year from received_date if not provided
  before_validation :set_income_period
  
  # Callbacks
  after_create :update_source_payment_status
  
  # Payment modes
  PAYMENT_MODES = %w[cash cheque online neft rtgs upi card].freeze
  
  private

  def set_income_period
    if received_date.present?
      self.income_month ||= received_date.month
      self.income_year  ||= received_date.year
    end
  end
  
  def update_source_payment_status
    return unless source_type == 'CamBill' && source_id.present?
    
    cam_bill = CamBill.find_by(id: source_id)
    return unless cam_bill
    
    # Calculate total paid for this bill
    total_paid = IncomeEntry.where(source_type: 'CamBill', source_id: cam_bill.id, status: 'received').sum(:amount)
    
    # Update payment status
    if total_paid >= cam_bill.total_amount
      cam_bill.update(payment_status: 'paid')
    elsif total_paid > 0
      cam_bill.update(payment_status: 'partial')
    end
  end
end
