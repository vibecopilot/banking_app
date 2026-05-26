class AddColumnToLoiDetails < ActiveRecord::Migration[5.1]
  def change
    add_column :loi_items, :expected_date, :datetime
  end
end
