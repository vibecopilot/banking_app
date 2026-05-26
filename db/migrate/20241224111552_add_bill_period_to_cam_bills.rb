class AddBillPeriodToCamBills < ActiveRecord::Migration[5.1]
  def change
    add_column :cam_bills, :bill_period_start_date, :date
    add_column :cam_bills, :bill_period_end_date, :date
  end
end
