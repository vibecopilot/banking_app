class JournalEntry < ApplicationRecord
  # Associations
  belongs_to :site
  belongs_to :unit, optional: true
  belongs_to :created_by, class_name: 'User', foreign_key: 'created_by_id'
  belongs_to :posted_by, class_name: 'User', foreign_key: 'posted_by_id', optional: true
  has_many :journal_entry_lines, dependent: :destroy
  has_many :ledgers, through: :journal_entry_lines

  # Polymorphic association for reference
  belongs_to :reference, polymorphic: true, optional: true

  # Validations
  validates :entry_number, presence: true, uniqueness: { scope: :site_id }
  validates :entry_date, presence: true
  validates :site_id, presence: true
  validates :status, inclusion: { in: %w[draft posted cancelled] }
  validate :debits_equal_credits, if: :posting?

  # Scopes
  scope :for_site, ->(site_id) { where(site_id: site_id) }
  scope :for_unit, ->(unit_id) { where(unit_id: unit_id) }
  scope :posted, -> { where(status: 'posted') }
  scope :draft, -> { where(status: 'draft') }
  scope :by_date_range, ->(from, to) { where(entry_date: from..to) }
  scope :by_type, ->(type) { where(entry_type: type) }

  # Use expense_month/expense_year when available, fallback to entry_date.
  # start_month, end_month are integers (1-12); year is integer.
  scope :by_expense_period, ->(year, start_month, end_month = nil) {
    end_month ||= start_month
    period_start = Date.new(year, start_month, 1)
    period_end   = Date.new(year, end_month, -1)
    where(
      "(expense_month IS NOT NULL AND expense_year IS NOT NULL " \
      "AND expense_year = ? AND expense_month BETWEEN ? AND ?) " \
      "OR ((expense_month IS NULL OR expense_year IS NULL) " \
      "AND entry_date BETWEEN ? AND ?)",
      year, start_month, end_month, period_start, period_end
    )
  }

  # Date-range version: uses expense_month/year when set, else entry_date
  scope :by_expense_date_range, ->(from_date, to_date) {
    where(
      "(expense_month IS NOT NULL AND expense_year IS NOT NULL " \
      "AND ((expense_year > ? OR (expense_year = ? AND expense_month >= ?)) " \
      "AND  (expense_year < ? OR (expense_year = ? AND expense_month <= ?)))) " \
      "OR ((expense_month IS NULL OR expense_year IS NULL) " \
      "AND entry_date BETWEEN ? AND ?)",
      from_date.year, from_date.year, from_date.month,
      to_date.year, to_date.year, to_date.month,
      from_date, to_date
    )
  }

  # Callbacks
  before_validation :generate_entry_number, on: :create
  before_save :recalculate_totals
  after_save :update_ledger_balances, if: :saved_change_to_status?

  accepts_nested_attributes_for :journal_entry_lines, allow_destroy: true

  # Instance methods
  def post!(user)
    return false unless can_post?
    transaction do
      self.status = 'posted'
      self.posted_by = user
      self.posted_at = Time.current
      save!
      update_ledger_balances
    end
    true
  rescue => e
    errors.add(:base, "Failed to post entry: #{e.message}")
    false
  end

  def cancel!
    return false if status == 'cancelled'

    transaction do
      self.status = 'cancelled'
      save!
      update_ledger_balances
    end

    true
  end

  def can_post?
    status == 'draft' && balanced? && journal_entry_lines.any?
  end

  def balanced?
    (total_debit - total_credit).abs < 0.01
  end

  def posting?
    status_changed? && status == 'posted'
  end
  # Public: recalc totals used by line callbacks
  def recalculate_totals
    self.total_debit = journal_entry_lines.where(entry_side: 'debit').sum(:amount)
    self.total_credit = journal_entry_lines.where(entry_side: 'credit').sum(:amount)
  end
  alias_method :calculate_totals, :recalculate_totals

  private

  def generate_entry_number
    return if entry_number.present?
    last_entry = JournalEntry.where(site_id: site_id)
    .where('entry_date >= ?', entry_date.beginning_of_year)
    .order(entry_number: :desc)
    .first
    if last_entry && last_entry.entry_number.match(/JE-(\d{4})-(\d+)/)
      year = $1
      number = $2.to_i + 1
    else
      year = entry_date.year
      number = 1
    end
    self.entry_number = "JE-#{year}-#{number.to_s.rjust(5, '0')}"
  end

  def debits_equal_credits
    unless balanced?
      errors.add(:base, "Total debits (#{total_debit}) must equal total credits (#{total_credit})")
    end
  end

  def update_ledger_balances
    return unless status == 'posted'
    ledger_ids = journal_entry_lines.pluck(:ledger_id).uniq
    ledger_ids.each do |ledger_id|
      ledger = Ledger.find(ledger_id)
      ledger.update_balance!
    end
  end
end
