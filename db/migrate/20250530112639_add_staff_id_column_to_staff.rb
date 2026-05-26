class AddStaffIdColumnToStaff < ActiveRecord::Migration[5.1]
  def change
    add_column :staffs, :staff_id, :string
    add_index :staffs, :staff_id, unique: true
  end
end
