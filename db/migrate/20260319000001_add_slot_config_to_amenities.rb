class AddSlotConfigToAmenities < ActiveRecord::Migration[5.1]
  def change
    add_column :amenities, :slot_start_time, :time unless column_exists?(:amenities, :slot_start_time)
    add_column :amenities, :slot_end_time, :time unless column_exists?(:amenities, :slot_end_time)
    add_column :amenities, :concurrent_slot, :integer, default: 1 unless column_exists?(:amenities, :concurrent_slot)
    add_column :amenities, :slot_by, :string unless column_exists?(:amenities, :slot_by)
    add_column :amenities, :wrap_time, :integer, default: 0 unless column_exists?(:amenities, :wrap_time)
  end
end
