class AddRecalReasonToCamBill < ActiveRecord::Migration[5.1]
  def change
    add_column :cam_bills, :recall_reason, :text
    add_column :cam_bills, :status, :string
  end
end
