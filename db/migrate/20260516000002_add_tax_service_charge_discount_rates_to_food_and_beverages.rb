class AddTaxServiceChargeDiscountRatesToFoodAndBeverages < ActiveRecord::Migration[5.1]
  def change
    add_column :food_and_beverages, :cgst_rate, :float, default: 0.0
    add_column :food_and_beverages, :sgst_rate, :float, default: 0.0
    add_column :food_and_beverages, :igst_rate, :float, default: 0.0
    add_column :food_and_beverages, :service_charge_percent, :float, default: 0.0
    add_column :food_and_beverages, :discount_percent, :float, default: 0.0
  end
end
