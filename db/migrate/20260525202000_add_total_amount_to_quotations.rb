class AddTotalAmountToQuotations < ActiveRecord::Migration[5.2]
  def change
    add_column :quotations, :total_amount, :decimal, precision: 12, scale: 2, default: 0.0
  end
end
