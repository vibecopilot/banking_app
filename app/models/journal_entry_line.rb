class JournalEntryLine < ApplicationRecord
  # Associations
  belongs_to :journal_entry
  belongs_to :ledger
  belongs_to :unit, optional: true

  # Validations
  validates :ledger_id, presence: true
  validates :entry_side, presence: true, inclusion: { in: %w[debit credit] }
  validates :amount, presence: true, numericality: { greater_than: 0 }

  # Scopes
  scope :debits, -> { where(entry_side: 'debit') }
  scope :credits, -> { where(entry_side: 'credit') }
  scope :for_ledger, ->(ledger_id) { where(ledger_id: ledger_id) }
  scope :for_unit, ->(unit_id) { where(unit_id: unit_id) }

  # Callbacks
  after_save :update_journal_totals
  after_destroy :update_journal_totals

  # Instance methods
  def debit?
    entry_side == 'debit'
  end

  def credit?
    entry_side == 'credit'
  end

  private

  def update_journal_totals
    journal_entry.recalculate_totals
    journal_entry.save! if journal_entry.persisted?
  end
end
