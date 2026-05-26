class AddIncomeMonthYearToAccountingInvoicesAndIncomeEntries < ActiveRecord::Migration[5.2]
  def change
    add_column :accounting_invoices, :income_month, :integer
    add_column :accounting_invoices, :income_year, :integer

    add_column :income_entries, :income_month, :integer
    add_column :income_entries, :income_year, :integer
  end
end
