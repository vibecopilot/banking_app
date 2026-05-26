class AddFieldsToVisitors < ActiveRecord::Migration[5.1]
  def change
    add_column :visitors, :coming_from, :string
    add_column :visitors, :vehicle_number, :string
    add_column :visitors, :expected_date, :date
    add_column :visitors, :expected_time, :time
    add_column :visitors, :skip_host_approval, :boolean, default: false
    add_column :visitors, :goods_inwards, :boolean, default: false
    add_column :visitors, :visit_type, :string
    add_column :visitors, :frequency, :string
    add_column :visitors, :working_days, :text
  end
end
