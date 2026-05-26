class AddPassStartDateToVisitors < ActiveRecord::Migration[5.1]
  def change
    add_column :visitors, :pass_start_date, :date
    add_column :visitors, :pass_end_date, :date
  end
end
