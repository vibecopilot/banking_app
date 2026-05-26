class AddSiteIdToGroup < ActiveRecord::Migration[5.1]
  def change
    add_column :groups, :site_id, :integer
  end
end
