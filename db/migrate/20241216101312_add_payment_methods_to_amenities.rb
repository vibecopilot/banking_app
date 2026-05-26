class AddPaymentMethodsToAmenities < ActiveRecord::Migration[5.1]
  def change
    add_column :amenities, :payment_methods, :json
    add_column :amenities, :tenant_price_adult, :integer
    add_column :amenities, :tenant_price_child, :integer
  end
end
