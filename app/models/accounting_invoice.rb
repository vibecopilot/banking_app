class AccountingInvoice < ApplicationRecord
  # Virtual attribute to detect when total_amount is set manually
  attr_accessor :manual_total_amount_set

  # Associations
  belongs_to :site
  belongs_to :unit, optional: true
  belongs_to :user, optional: true
  belongs_to :vendor, optional: true
  belongs_to :created_by, class_name: 'User', foreign_key: :created_by_id
  belongs_to :journal_entry, optional: true
  has_many :accounting_invoice_items, dependent: :destroy
  has_many :accounting_payments, dependent: :restrict_with_error

  # Validations
  validates :invoice_number, presence: true, uniqueness: true
  validates :invoice_date, presence: true
  validates :site_id, presence: true
  validates :status, inclusion: { in: %w[draft sent paid partially_paid overdue cancelled] }

  # Callbacks
  before_validation :generate_invoice_number, on: :create
  before_validation :set_default_status, on: :create
  before_save :calculate_amounts
  after_save :update_status_based_on_payments
  after_create :create_journal_entry_for_invoice
  after_update :create_journal_entry_for_invoice, if: :saved_change_to_status?

  accepts_nested_attributes_for :accounting_invoice_items, allow_destroy: true

  # Scopes
  scope :for_site, ->(site_id) { where(site_id: site_id) }
  scope :for_unit, ->(unit_id) { where(unit_id: unit_id) }
  scope :for_user, ->(user_id) { where(user_id: user_id) }
  scope :by_status, ->(status) { where(status: status) }
  scope :by_type, ->(type) { where(invoice_type: type) }
  scope :unpaid, -> { where(status: ['sent', 'overdue']) }
  scope :overdue, -> { where('due_date < ? AND status IN (?)', Date.current, ['sent', 'partially_paid']) }

  # Instance methods
  def mark_as_sent!
    update(status: 'sent', sent_at: Time.current)
  end

  def add_payment(amount, payment_attrs = {})
    payment = accounting_payments.build(payment_attrs.merge(
      amount: amount,
      site_id: site_id,
      unit_id: unit_id,
      user_id: user_id
    ))
    if payment.save
      reload
      update_payment_status!
      true
    else
      false
    end
  end

  def update_payment_status!
    self.paid_amount = accounting_payments.sum(:amount)
    self.balance_amount = total_amount - paid_amount
    
    self.status = if paid_amount >= total_amount
      self.paid_at = Time.current
      'paid'
    elsif paid_amount > 0
      'partially_paid'
    elsif due_date && due_date < Date.current
      'overdue'
    else
      'sent'
    end
    
    save!
  end

  def overdue?
    due_date.present? && due_date < Date.current && balance_amount.to_f > 0
  end

  def days_overdue
    return 0 unless overdue?
    (Date.current - due_date).to_i
  end

  # Track when total_amount is explicitly set (e.g. from console or API)
  def total_amount=(value)
    self.manual_total_amount_set = true unless value.nil?
    super
  end

  def calculate_amounts
    has_items = accounting_invoice_items.loaded? ? accounting_invoice_items.any? : accounting_invoice_items.exists?

    if has_items
      # When there are line items, always derive amounts from them
      self.subtotal = accounting_invoice_items.sum(:amount)
      self.tax_amount = accounting_invoice_items.sum(:tax_amount)
      self.total_amount = subtotal.to_f + tax_amount.to_f
    else
      # When there are no items (simple/manual invoice)
      self.subtotal ||= 0
      self.tax_amount ||= 0

      # If total_amount was explicitly set in this lifecycle, keep it.
      # Otherwise, derive from subtotal + tax (or fallback to 0).
      unless manual_total_amount_set
        self.total_amount = (total_amount.presence || (subtotal.to_f + tax_amount.to_f))
      end
    end

    # Ensure paid_amount is not nil
    self.paid_amount ||= 0

    # Balance is always derived from total and paid
    self.balance_amount = total_amount.to_f - paid_amount.to_f
  end

  private

  def set_default_status
    self.status ||= 'draft'
  end

 def generate_invoice_number
  return if invoice_number.present?

  prefix = case invoice_type
           when 'unit_maintenance' then 'INV'
           when 'cam_charges'      then 'CAM'
           when 'utility'          then 'UTIL'
           when 'vendor_bill'      then 'EXP'
           else 'INV'
           end

  date = invoice_date || Date.current
  month_year = date.strftime('%b%y').upcase # JAN26

  base_prefix = "#{prefix}-#{month_year}"

  # Get last invoice number for same prefix + month
  last_invoice = AccountingInvoice
    .where("invoice_number LIKE ?", "#{base_prefix}-%")
    .order(invoice_number: :desc)
    .limit(1)
    .pluck(:invoice_number)
    .first

  next_sequence =
    if last_invoice.present?
      last_invoice.split('-').last.to_i + 1
    else
      1
    end

  self.invoice_number = format(
    "%s-%03d",
    base_prefix,
    next_sequence
  )
end

  def update_status_based_on_payments
    return unless saved_change_to_total_amount?
    update_payment_status!
  end

  def create_journal_entry_for_invoice
    return if journal_entry.present? || status == 'draft'

    is_vendor_bill = invoice_type.to_s == 'vendor_bill'

    entry = JournalEntry.new(
      site_id: site_id,
      unit_id: unit_id,
      entry_date: invoice_date,
      entry_type: is_vendor_bill ? 'vendor_bill' : 'invoice',
      reference: self,
      narration: if is_vendor_bill
        "Vendor Bill #{invoice_number} - #{vendor&.vendor_name || vendor&.company_name || 'N/A'}"
      else
        "Invoice #{invoice_number} - #{unit&.name || 'N/A'}"
      end,
      created_by: created_by
    )

    if is_vendor_bill
      payable_ledger = Ledger.find_by(code: 'L-PAYABLE', site_id: site_id)
      gst_input_ledger = Ledger.find_by(code: 'L-GST-IN', site_id: site_id)

      # Debit: Expense ledgers + GST input (if any)
      accounting_invoice_items.each do |item|
        if item.ledger
          entry.journal_entry_lines.build(
            ledger: item.ledger,
            entry_side: 'debit',
            amount: item.amount,
            description: item.description,
            unit_id: unit_id
          )
        end

        if item.tax_amount.to_f > 0
          tax_ledger = item.tax_rate&.ledger || gst_input_ledger
          if tax_ledger
            entry.journal_entry_lines.build(
              ledger: tax_ledger,
              entry_side: 'debit',
              amount: item.tax_amount,
              description: "Tax on #{item.description}",
              unit_id: unit_id
            )
          end
        end
      end

      # Credit: Vendor Payable (total)
      if payable_ledger
        entry.journal_entry_lines.build(
          ledger: payable_ledger,
          entry_side: 'credit',
          amount: total_amount,
          description: "Vendor Bill #{invoice_number}",
          unit_id: unit_id
        )
      end
    else
      receivable_ledger = Ledger.find_by(code: 'L-RECV', site_id: site_id)
      gst_output_ledger = Ledger.find_by(code: 'L-GST-OUT', site_id: site_id)

      # Debit: Accounts Receivable
      if receivable_ledger
        entry.journal_entry_lines.build(
          ledger: receivable_ledger,
          entry_side: 'debit',
          amount: total_amount,
          description: "Invoice #{invoice_number}",
          unit_id: unit_id
        )
      end

      # Credit: Income ledgers + GST output (if any)
      accounting_invoice_items.each do |item|
        if item.ledger
          entry.journal_entry_lines.build(
            ledger: item.ledger,
            entry_side: 'credit',
            amount: item.amount,
            description: item.description,
            unit_id: unit_id
          )
        end

        if item.tax_amount.to_f > 0
          tax_ledger = item.tax_rate&.ledger || gst_output_ledger
          if tax_ledger
            entry.journal_entry_lines.build(
              ledger: tax_ledger,
              entry_side: 'credit',
              amount: item.tax_amount,
              description: "Tax on #{item.description}",
              unit_id: unit_id
            )
          end
        end
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
      entry.post!(created_by) if status == 'sent'
    end
  end
end
