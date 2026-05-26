class AddSiteIdToStaffs < ActiveRecord::Migration[5.1]
  def change
    add_column :staffs, :site_id, :integer
  end
end
