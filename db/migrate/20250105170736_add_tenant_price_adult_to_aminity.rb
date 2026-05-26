class AddTenantPriceAdultToAminity < ActiveRecord::Migration[5.1]
  def change
    
    add_column :aminities, :tenant_price_adult, :float
    add_column :aminities, :tenant_price_children, :float
  end
end
