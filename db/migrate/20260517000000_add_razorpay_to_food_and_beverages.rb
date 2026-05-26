class AddRazorpayToFoodAndBeverages < ActiveRecord::Migration[5.2]
  def change
    add_column :food_and_beverages, :razorpay_enabled, :boolean, default: false
    add_column :food_and_beverages, :razorpay_key, :string
    add_column :food_and_beverages, :razorpay_secret, :string
  end
end
