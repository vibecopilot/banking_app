class AddGstNoToOtherBill < ActiveRecord::Migration[5.1]
  def change
    add_column :other_bills, :gst_no, :string
    add_column :other_bills, :pan_no, :string
  end
end
