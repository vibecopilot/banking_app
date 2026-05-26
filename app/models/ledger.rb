class Ledger < ApplicationRecord
  # Associations
  belongs_to :account_group
  belongs_to :site
  belongs_to :unit, optional: true
  has_many :journal_entry_lines, dependent: :restrict_with_error
  has_many :journal_entries, through: :journal_entry_lines
  has_many :tax_rates, dependent: :nullify

  # Validations
  validates :name, presence: true
  # validates :code, presence: true, uniqueness: { scope: :site_id }
  validates :account_group_id, presence: true
  validates :site_id, presence: true
  validates :ledger_type, inclusion: { in: %w[general unit_specific vendor customer], allow_blank: true }

  # Scopes
  scope :active, -> { where(active: true) }
  scope :for_site, ->(site_id) { where(site_id: site_id) }
  scope :for_unit, ->(unit_id) { where(unit_id: unit_id) }
  scope :general, -> { where(ledger_type: 'general') }
  scope :unit_specific, -> { where(ledger_type: 'unit_specific') }
  scope :organization_wide, -> { where(unit_id: nil) }
  scope :by_group_type, ->(type) { joins(:account_group).where(account_groups: { group_type: type }) }
  scope :by_group, ->(group_id) { where(account_group_id: group_id) }

  # Callbacks
  before_destroy :check_if_system_ledger
  before_validation :generate_code, if: -> { code.blank? }
  after_initialize :set_defaults

  # Instance methods
  def debit_nature?
    account_group.debit_nature?
  end

  def credit_nature?
    account_group.credit_nature?
  end

# Update Ledger From JournalEntry
  def update_balance!
    debit_sum = journal_entry_lines.where(entry_side: 'debit').sum(:amount)
    credit_sum = journal_entry_lines.where(entry_side: 'credit').sum(:amount)
    if debit_nature?
      self.current_balance = opening_balance + debit_sum - credit_sum
    else
      self.current_balance = opening_balance + credit_sum - debit_sum
    end
    save!
  end

  def balance_as_on(date)
    debit_sum = journal_entry_lines
      .joins(:journal_entry)
      .where('journal_entries.entry_date <= ? AND journal_entries.status = ?', date, 'posted')
      .where(entry_side: 'debit')
      .sum(:amount)
    
    credit_sum = journal_entry_lines
      .joins(:journal_entry)
      .where('journal_entries.entry_date <= ? AND journal_entries.status = ?', date, 'posted')
      .where(entry_side: 'credit')
      .sum(:amount)
    
    if debit_nature?
      opening_balance + debit_sum - credit_sum
    else
      opening_balance + credit_sum - debit_sum
    end
  end

  def balance_sheet(start_date = nil, end_date = nil)
    lines = journal_entry_lines
      .joins(:journal_entry)
      .where('journal_entries.status = ?', 'posted')
    
    lines = lines.where('journal_entries.entry_date >= ?', start_date) if start_date
    lines = lines.where('journal_entries.entry_date <= ?', end_date) if end_date
    
    {
      opening_balance: opening_balance,
      transactions: lines.order('journal_entries.entry_date'),
      closing_balance: current_balance
    }
  end

  def full_name
    parts = [account_group.full_name, name]
    parts << "(#{unit.name})" if unit_id.present? && unit
    parts.join(' - ')
  end

  private

  def generate_code
    prefix = "LDG"
    timestamp = Time.current.strftime("%y%m%d")
    random_suffix = SecureRandom.alphanumeric(4).upcase
    self.code = "#{prefix}-#{timestamp}-#{random_suffix}"
    
    # Ensure uniqueness within site
    while Ledger.exists?(code: self.code, site_id: self.site_id)
      random_suffix = SecureRandom.alphanumeric(4).upcase
      self.code = "#{prefix}-#{timestamp}-#{random_suffix}"
    end
  end

  def check_if_system_ledger
    if is_system?
      errors.add(:base, 'Cannot delete system-defined ledger')
      throw(:abort)
    end
  end

  def set_defaults
    self.ledger_type ||= 'general'
    self.opening_balance ||= 0.0
    self.current_balance ||= opening_balance
    self.advance_amount ||= 0.0
  end

  # Class methods
  def self.seed_default_ledgers(site_id)
    account_groups = AccountGroup.where(site_id: [site_id, nil]).index_by(&:code)
    
    ledgers = [
      { code: 'L-CASH', name: 'Cash in Hand', group_code: 'A001-01', ledger_type: 'general', is_system: true },
      { code: 'L-BANK', name: 'Bank Account', group_code: 'A001-02', ledger_type: 'general', is_system: true },
      { code: 'L-RECV', name: 'Unit Receivables', group_code: 'A001-03', ledger_type: 'general', is_system: true },
      { code: 'L-PAYABLE', name: 'Vendor Payables', group_code: 'L001-01', ledger_type: 'general', is_system: true },
      { code: 'L-GST-OUT', name: 'GST Output', group_code: 'L001-02', ledger_type: 'general', is_system: true },
      { code: 'L-GST-IN', name: 'GST Input', group_code: 'A001', ledger_type: 'general', is_system: true },
      { code: 'L-MAINT', name: 'Maintenance Income', group_code: 'I001-01', ledger_type: 'general', is_system: true },
      { code: 'L-CAM', name: 'CAM Income', group_code: 'I001-02', ledger_type: 'general', is_system: true },
      { code: 'L-SALARY', name: 'Salaries', group_code: 'X001-01', ledger_type: 'general', is_system: true },
      { code: 'L-UTIL', name: 'Utilities Expense', group_code: 'X001-02', ledger_type: 'general', is_system: true },
    ]
    
    ledgers.each do |ledger_data|
      group_code = ledger_data.delete(:group_code)
      account_group = account_groups[group_code]
      next unless account_group
      
      Ledger.find_or_create_by(code: ledger_data[:code], site_id: site_id) do |l|
        l.name = ledger_data[:name]
        l.account_group = account_group
        l.ledger_type = ledger_data[:ledger_type]
        l.is_system = ledger_data[:is_system]
        l.active = true
      end
    end
  end
end
