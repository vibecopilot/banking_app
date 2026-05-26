class AddSiteIdToCamUnitBills < ActiveRecord::Migration[5.1]
  def change
    unless column_exists?(:cam_unit_bills, :site_id)
      add_column :cam_unit_bills, :site_id, :bigint
      add_index :cam_unit_bills, :site_id
    end
  end
end
