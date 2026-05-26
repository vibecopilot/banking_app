class AddSiteIdToPatrolling < ActiveRecord::Migration[5.1]
  def change
    add_column :patrollings, :site_id, :integer
  end
end
