class AddSiteIdToPermintEntity < ActiveRecord::Migration[5.1]
  def change
    add_column :permit_entities, :site_id, :integer
  end
end
