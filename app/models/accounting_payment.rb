class AccountingPayment < ApplicationRecord
  # Associations
  belongs_to :site
  belongs_to :unit, optional: true
  belongs_to :accounting_invoice, optional: true
  belongs_to :user, optional: true
  belongs_to :vendor, optional: true
  belongs_to :received_by, class_name: 'User', foreign_key: 'received_by_id', optional: true
  belongs_to :created_by, class_name: 'User', foreign_key: 'created_by_id'
  belongs_to :journal_entry, optional: true

  # Validations
  validates :payment_number, presence: true, uniqueness: true
  validates :payment_date, presence: true
  validates :site_id, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :payment_type, presence: true, inclusion: { in: %w[received paid] }
  validates :payment_mode, inclusion: { in: %w[cash cheque bank_transfer upi card online], allow_blank: true }

  # Callbacks
  before_validation :generate_payment_number, on: :create
  after_create :create_journal_entry_for_payment
  after_save :update_invoice_payment_status

  # Scopes
  scope :for_site, ->(site_id) { where(site_id: site_id) }
  scope :for_unit, ->(unit_id) { where(unit_id: unit_id) }
  scope :for_invoice, ->(invoice_id) { where(accounting_invoice_id: invoice_id) }
  scope :received, -> { where(payment_type: 'received') }
  scope :paid, -> { where(payment_type: 'paid') }
  scope :by_date_range, ->(from, to) { where(payment_date: from..to) }

  # Instance methods
  def payment_received?
    payment_type == 'received'
  end

  def payment_made?
    payment_type == 'paid'
  end

  private

  def generate_payment_number
    return if payment_number.present?
    
    prefix = payment_type == 'received' ? 'PMT-RCV' : 'PMT-PAID'
    
    last_payment = AccountingPayment.where(site_id: site_id)
      .where('payment_date >= ?', payment_date.beginning_of_year)
      .where('payment_number LIKE ?', "#{prefix}-%")
      .order(payment_number: :desc)
      .first
    
    if last_payment && last_payment.payment_number.match(/#{prefix}-(\d{4})-(\d+)/)
      year = $1
      number = $2.to_i + 1
    else
      year = payment_date.year
      number = 1
    end
    
    self.payment_number = "#{prefix}-#{year}-#{number.to_s.rjust(5, '0')}"
  end

  def create_journal_entry_for_payment
    entry = JournalEntry.new(
      site_id: site_id,
      unit_id: unit_id,
      entry_date: payment_date,
      entry_type: 'payment',
      reference: self,
      narration: "Payment #{payment_number} - #{payment_mode}",
      created_by: created_by
    )
    
    bank_ledger = Ledger.find_by(code: 'L-BANK', site_id: site_id)
    cash_ledger = Ledger.find_by(code: 'L-CASH', site_id: site_id)
    receivable_ledger = Ledger.find_by(code: 'L-RECV', site_id: site_id)
    payable_ledger = Ledger.find_by(code: 'L-PAYABLE', site_id: site_id)
    
    if payment_received?
      # Payment received: Debit Bank/Cash, Credit Receivable
      payment_ledger = payment_mode == 'cash' ? cash_ledger : bank_ledger
      
      if payment_ledger
        entry.journal_entry_lines.build(
          ledger: payment_ledger,
          entry_side: 'debit',
          amount: amount,
          description: "Payment received via #{payment_mode}",
          unit_id: unit_id
        )
      end
      
      if receivable_ledger
        entry.journal_entry_lines.build(
          ledger: receivable_ledger,
          entry_side: 'credit',
          amount: amount,
          description: "Payment against #{accounting_invoice&.invoice_number || 'account'}",
          unit_id: unit_id
        )
      end
    else
      # Payment made: Debit Payable, Credit Bank/Cash
      if payable_ledger
        entry.journal_entry_lines.build(
          ledger: payable_ledger,
          entry_side: 'debit',
          amount: amount,
          description: "Payment to vendor",
          unit_id: unit_id
        )
      end
      
      payment_ledger = payment_mode == 'cash' ? cash_ledger : bank_ledger
      if payment_ledger
        entry.journal_entry_lines.build(
          ledger: payment_ledger,
          entry_side: 'credit',
          amount: amount,
          description: "Payment made via #{payment_mode}",
          unit_id: unit_id
        )
      end
    end

    lines = entry.journal_entry_lines
    return if lines.empty?

    debit_total = lines.select { |l| l.entry_side == 'debit' }.sum { |l| l.amount.to_f }
    credit_total = lines.select { |l| l.entry_side == 'credit' }.sum { |l| l.amount.to_f }

    return if debit_total <= 0 || credit_total <= 0
    return if (debit_total - credit_total).abs > 0.01

    if entry.save
      update_column(:journal_entry_id, entry.id)
      entry.post!(created_by)
    end
  end

  def update_invoice_payment_status
    return unless accounting_invoice_id.present?
    accounting_invoice.update_payment_status!
  end
end
