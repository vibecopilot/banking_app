class AddSiteIdToCamBill < ActiveRecord::Migration[5.1]
  def change
    add_column :cam_bills, :site_id, :integer
  end
end
