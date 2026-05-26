class AddSiteIdToMomDetails < ActiveRecord::Migration[5.1]
  def change
    add_column :mom_details, :site_id, :integer
  end
end
