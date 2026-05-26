class AddAdvanceAmountToLedgers < ActiveRecord::Migration[5.2]
  def change
    add_column :ledgers, :advance_amount, :decimal, precision: 15, scale: 2, default: 0.0
  end
end
