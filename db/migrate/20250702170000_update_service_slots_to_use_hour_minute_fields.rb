class UpdateServiceSlotsToUseHourMinuteFields < ActiveRecord::Migration[5.1]
  def up
    # Add the new hour/minute fields only if they don't exist
    add_column :service_slots, :start_hr, :integer unless column_exists?(:service_slots, :start_hr)
    add_column :service_slots, :end_hr, :integer unless column_exists?(:service_slots, :end_hr)
    add_column :service_slots, :start_min, :integer unless column_exists?(:service_slots, :start_min)
    add_column :service_slots, :end_min, :integer unless column_exists?(:service_slots, :end_min)
    
    # Make the old time fields nullable temporarily (only if they're currently NOT NULL)
    if column_exists?(:service_slots, :start_time)
      change_column_null :service_slots, :start_time, true
    end
    
    if column_exists?(:service_slots, :end_time)
      change_column_null :service_slots, :end_time, true
    end
    
    # Migrate existing data from time fields to hour/minute fields
    ServiceSlot.reset_column_information
    ServiceSlot.find_each do |slot|
      if slot.respond_to?(:start_time) && slot.respond_to?(:end_time) && 
         slot.start_time.present? && slot.end_time.present? &&
         (slot.start_hr.blank? || slot.start_min.blank? || slot.end_hr.blank? || slot.end_min.blank?)
        
        slot.update_columns(
          start_hr: slot.start_time.hour,
          start_min: slot.start_time.min,
          end_hr: slot.end_time.hour,
          end_min: slot.end_time.min
        )
      end
    end
  end
  
  def down
    # Remove the new fields only if they exist
    remove_column :service_slots, :start_hr if column_exists?(:service_slots, :start_hr)
    remove_column :service_slots, :end_hr if column_exists?(:service_slots, :end_hr)
    remove_column :service_slots, :start_min if column_exists?(:service_slots, :start_min)
    remove_column :service_slots, :end_min if column_exists?(:service_slots, :end_min)
    
    # Restore NOT NULL constraint on time fields (only if they exist)
    if column_exists?(:service_slots, :start_time)
      change_column_null :service_slots, :start_time, false
    end
    
    if column_exists?(:service_slots, :end_time)
      change_column_null :service_slots, :end_time, false
    end
  end
end
