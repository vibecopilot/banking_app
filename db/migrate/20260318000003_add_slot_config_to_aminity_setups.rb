class AddSlotConfigToAminitySetups < ActiveRecord::Migration[5.1]
  def change
    add_column :aminity_setups, :slot_start_time, :time unless column_exists?(:aminity_setups, :slot_start_time)
    add_column :aminity_setups, :slot_end_time, :time unless column_exists?(:aminity_setups, :slot_end_time)
    add_column :aminity_setups, :concurrent_slot, :integer, default: 1 unless column_exists?(:aminity_setups, :concurrent_slot)
    add_column :aminity_setups, :slot_by, :string unless column_exists?(:aminity_setups, :slot_by)
    add_column :aminity_setups, :wrap_time, :integer, default: 0 unless column_exists?(:aminity_setups, :wrap_time)
  end
end
