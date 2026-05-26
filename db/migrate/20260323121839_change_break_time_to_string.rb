class ChangeBreakTimeToString < ActiveRecord::Migration[5.2]
  def up
    add_column :amenities, :break_time_start_tmp, :string
    add_column :amenities, :break_time_end_tmp, :string

    Amenity.reset_column_information

    Amenity.find_each do |record|
      record.update_columns(
        break_time_start_tmp: record.break_time_start&.strftime("%H:%M"),
        break_time_end_tmp: record.break_time_end&.strftime("%H:%M")
      )
    end

    remove_column :amenities, :break_time_start
    remove_column :amenities, :break_time_end

    rename_column :amenities, :break_time_start_tmp, :break_time_start
    rename_column :amenities, :break_time_end_tmp, :break_time_end
  end

  def down
    add_column :amenities, :break_time_start_tmp, :datetime
    add_column :amenities, :break_time_end_tmp, :datetime

    Amenity.reset_column_information

    Amenity.find_each do |record|
      record.update_columns(
        break_time_start_tmp: record.break_time_start.present? ? Time.parse(record.break_time_start) : nil,
        break_time_end_tmp: record.break_time_end.present? ? Time.parse(record.break_time_end) : nil
      )
    end

    remove_column :amenities, :break_time_start
    remove_column :amenities, :break_time_end

    rename_column :amenities, :break_time_start_tmp, :break_time_start
    rename_column :amenities, :break_time_end_tmp, :break_time_end
  end
end