class AddloidColumnToLoiDetail < ActiveRecord::Migration[5.1]
  def change
    add_column :loi_details, :self_id, :integer
  end
end
