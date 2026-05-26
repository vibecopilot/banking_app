class EnhanceServicePricingsTable < ActiveRecord::Migration[5.1]
  def change
    # Ensure pricing calculation fields exist
    unless column_exists?(:service_pricings, :discount_amount)
      add_column :service_pricings, :discount_amount, :decimal, precision: 10, scale: 2, default: 0.0
    end
    
    unless column_exists?(:service_pricings, :tax_amount)
      add_column :service_pricings, :tax_amount, :decimal, precision: 10, scale: 2, default: 0.0
    end
    
    unless column_exists?(:service_pricings, :final_price)
      add_column :service_pricings, :final_price, :decimal, precision: 10, scale: 2, default: 0.0
    end
    
    # Ensure discount and tax percentage fields exist with proper defaults
    unless column_exists?(:service_pricings, :discount_percentage)
      add_column :service_pricings, :discount_percentage, :decimal, precision: 5, scale: 2, default: 0.0
    end
    
    unless column_exists?(:service_pricings, :tax_percentage)
      add_column :service_pricings, :tax_percentage, :decimal, precision: 5, scale: 2, default: 0.0
    end
  end
end
