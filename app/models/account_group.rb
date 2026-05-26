class AccountGroup < ApplicationRecord
  # Associations
  belongs_to :site, optional: true
  belongs_to :parent, class_name: 'AccountGroup', optional: true
  has_many :children, class_name: 'AccountGroup', foreign_key: 'parent_id', dependent: :destroy
  has_many :ledgers, dependent: :restrict_with_error

  # Validations
  validates :name, presence: true
  validates :code, presence: true, uniqueness: { scope: :site_id }
  validates :group_type, presence: true, inclusion: { in: %w[asset liability equity income expense] }

  # Scopes
  scope :active, -> { where(active: true) }
  scope :for_site, ->(site_id) { where(site_id: [site_id, nil]) }
  scope :assets, -> { where(group_type: 'asset') }
  scope :liabilities, -> { where(group_type: 'liability') }
  scope :equity, -> { where(group_type: 'equity') }
  scope :income, -> { where(group_type: 'income') }
  scope :expenses, -> { where(group_type: 'expense') }
  scope :root_groups, -> { where(parent_id: nil) }
  scope :ordered_by_type, -> {
    order(
      Arel.sql("CASE account_groups.group_type WHEN 'asset' THEN 1 WHEN 'liability' THEN 2 WHEN 'equity' THEN 3 WHEN 'income' THEN 4 WHEN 'expense' THEN 5 END, COALESCE(account_groups.parent_id, account_groups.id), account_groups.parent_id IS NOT NULL, account_groups.code")
    )
  }

  # Callbacks
  before_destroy :check_if_system_group

  # Instance methods
  def full_name
    parent ? "#{parent.full_name} > #{name}" : name
  end

  def debit_nature?
    %w[asset expense].include?(group_type)
  end

  def credit_nature?
    %w[liability equity income].include?(group_type)
  end

  def total_balance(site_id = nil)
    ledgers_scope = site_id ? ledgers.where(site_id: site_id) : ledgers
    ledgers_scope.sum(:current_balance)
  end

  private

  def check_if_system_group
    if is_system?
      errors.add(:base, 'Cannot delete system-defined account group')
      throw(:abort)
    end
  end

  # Class methods for seeding default account groups
  def self.seed_default_groups(site_id = nil)
    groups = [
      # Assets
      { code: 'A001', name: 'Current Assets', group_type: 'asset', parent_code: nil, is_system: true },
      { code: 'A001-01', name: 'Cash', group_type: 'asset', parent_code: 'A001', is_system: true },
      { code: 'A001-02', name: 'Bank Accounts', group_type: 'asset', parent_code: 'A001', is_system: true },
      { code: 'A001-03', name: 'Accounts Receivable', group_type: 'asset', parent_code: 'A001', is_system: true },
      { code: 'A002', name: 'Fixed Assets', group_type: 'asset', parent_code: nil, is_system: true },
      
      # Liabilities
      { code: 'L001', name: 'Current Liabilities', group_type: 'liability', parent_code: nil, is_system: true },
      { code: 'L001-01', name: 'Accounts Payable', group_type: 'liability', parent_code: 'L001', is_system: true },
      { code: 'L001-02', name: 'Tax Payable', group_type: 'liability', parent_code: 'L001', is_system: true },
      { code: 'L001-03', name: 'Advance from Units', group_type: 'liability', parent_code: 'L001', is_system: true },
      
      # Equity
      { code: 'E001', name: 'Owner\'s Equity', group_type: 'equity', parent_code: nil, is_system: true },
      { code: 'E001-01', name: 'Retained Earnings', group_type: 'equity', parent_code: 'E001', is_system: true },
      
      # Income
      { code: 'I001', name: 'Revenue', group_type: 'income', parent_code: nil, is_system: true },
      { code: 'I001-01', name: 'Maintenance Charges', group_type: 'income', parent_code: 'I001', is_system: true },
      { code: 'I001-02', name: 'CAM Charges', group_type: 'income', parent_code: 'I001', is_system: true },
      { code: 'I001-03', name: 'Utility Charges', group_type: 'income', parent_code: 'I001', is_system: true },
      
      # Expenses
      { code: 'X001', name: 'Operating Expenses', group_type: 'expense', parent_code: nil, is_system: true },
      { code: 'X001-01', name: 'Salary & Wages', group_type: 'expense', parent_code: 'X001', is_system: true },
      { code: 'X001-02', name: 'Utilities', group_type: 'expense', parent_code: 'X001', is_system: true },
      { code: 'X001-03', name: 'Maintenance & Repairs', group_type: 'expense', parent_code: 'X001', is_system: true },
    ]

    created_groups = {}
    
    groups.each do |group_data|
      parent_code = group_data.delete(:parent_code)
      parent = parent_code ? created_groups[parent_code] : nil
      
      group = AccountGroup.find_or_create_by(code: group_data[:code], site_id: site_id) do |g|
        g.name = group_data[:name]
        g.group_type = group_data[:group_type]
        g.parent = parent
        g.is_system = group_data[:is_system]
        g.active = true
      end
      
      created_groups[group_data[:code]] = group
    end
    
    created_groups
  end
end
