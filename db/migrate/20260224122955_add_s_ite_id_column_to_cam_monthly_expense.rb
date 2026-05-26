class AddSIteIdColumnToCamMonthlyExpense < ActiveRecord::Migration[5.1]
  def change
    add_column :monthly_expenses, :site_id, :integer
  end
end
