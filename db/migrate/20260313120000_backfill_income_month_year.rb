class BackfillIncomeMonthYear < ActiveRecord::Migration[5.2]
  def up
    # Backfill income_month/income_year from invoice_date for accounting_invoices
    execute <<-SQL
      UPDATE accounting_invoices
      SET income_month = MONTH(invoice_date),
          income_year = YEAR(invoice_date)
      WHERE income_month IS NULL
        AND income_year IS NULL
        AND invoice_date IS NOT NULL
    SQL

    # Backfill income_month/income_year from received_date for income_entries
    execute <<-SQL
      UPDATE income_entries
      SET income_month = MONTH(received_date),
          income_year = YEAR(received_date)
      WHERE income_month IS NULL
        AND income_year IS NULL
        AND received_date IS NOT NULL
    SQL
  end

  def down
    execute "UPDATE accounting_invoices SET income_month = NULL, income_year = NULL"
    execute "UPDATE income_entries SET income_month = NULL, income_year = NULL"
  end
end
