class AddColumnToOtherBill < ActiveRecord::Migration[5.1]
  def change
    add_column :other_bills, :created_by_id, :integer
  end
end
