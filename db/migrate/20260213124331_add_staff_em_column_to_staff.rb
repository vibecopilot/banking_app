class AddStaffEmColumnToStaff < ActiveRecord::Migration[5.1]
  def change
    add_column :staffs, :embedding, :text
    add_column :staffs, :date_of_birth, :date
    add_column :staffs, :staff_in_out, :string
  end
end
