class AddBreakTimeToAmenities < ActiveRecord::Migration[5.1]
  def change
    add_column :amenities, :break_time_start, :time unless column_exists?(:amenities, :break_time_start)
    add_column :amenities, :break_time_end, :time unless column_exists?(:amenities, :break_time_end)
  end
end
