class AddFieldsToCharge < ActiveRecord::Migration[5.1]
  def change
    add_column :charges, :discount_percentage, :float
    add_column :charges, :discount_amount, :float
    add_column :charges, :taxable_value, :string
  end
end
