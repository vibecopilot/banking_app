class AddJoiningDateToStaffs < ActiveRecord::Migration[5.1]
  def change
    add_column :staffs, :joining_date, :date unless column_exists?(:staffs, :joining_date)
  end
end
