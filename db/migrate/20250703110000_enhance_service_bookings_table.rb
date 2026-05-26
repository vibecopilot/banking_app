class EnhanceServiceBookingsTable < ActiveRecord::Migration[5.1]
  def change
    # Add unit_configuration_id reference
    add_reference :service_bookings, :unit_configuration, null: true, foreign_key: true, index: true
    
    # Ensure pricing fields exist with proper types
    unless column_exists?(:service_bookings, :total_amount)
      add_column :service_bookings, :total_amount, :decimal, precision: 10, scale: 2, default: 0.0
    end
    
    unless column_exists?(:service_bookings, :discount_amount)
      add_column :service_bookings, :discount_amount, :decimal, precision: 10, scale: 2, default: 0.0
    end
    
    unless column_exists?(:service_bookings, :tax_amount)
      add_column :service_bookings, :tax_amount, :decimal, precision: 10, scale: 2, default: 0.0
    end
    
    unless column_exists?(:service_bookings, :final_amount)
      add_column :service_bookings, :final_amount, :decimal, precision: 10, scale: 2, default: 0.0
    end
    
    # Add cancellation fields
    unless column_exists?(:service_bookings, :cancellation_reason)
      add_column :service_bookings, :cancellation_reason, :text
    end
    
    unless column_exists?(:service_bookings, :cancelled_at)
      add_column :service_bookings, :cancelled_at, :datetime
    end
    
    # Add service timing fields
    unless column_exists?(:service_bookings, :service_started_at)
      add_column :service_bookings, :service_started_at, :datetime
    end
    
    unless column_exists?(:service_bookings, :service_completed_at)
      add_column :service_bookings, :service_completed_at, :datetime
    end
  end
end
