class AddDateToCamBill < ActiveRecord::Migration[5.1]
  def change
    add_column :cam_bills, :supply_date, :date
  end
end
