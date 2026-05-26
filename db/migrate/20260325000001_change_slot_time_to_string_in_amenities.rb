class ChangeSlotTimeToStringInAmenities < ActiveRecord::Migration[5.2]
  def up
    change_column :amenities, :slot_start_time, :string
    change_column :amenities, :slot_end_time, :string

    Amenity.reset_column_information

    # Convert existing time values to "HH:MM" strings
    Amenity.find_each do |record|
      updates = {}
      updates[:slot_start_time] = record.slot_start_time.strftime("%H:%M") if record.slot_start_time.is_a?(Time)
      updates[:slot_end_time] = record.slot_end_time.strftime("%H:%M") if record.slot_end_time.is_a?(Time)
      record.update_columns(updates) if updates.present?
    end
  end

  def down
    change_column :amenities, :slot_start_time, :time
    change_column :amenities, :slot_end_time, :time
  end
end
