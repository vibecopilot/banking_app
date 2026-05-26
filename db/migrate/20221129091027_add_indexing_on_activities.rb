class AddIndexingOnActivities < ActiveRecord::Migration[5.1]
  def change
    add_index :activities, [:asset_id, :checklist_id, :start_time]
  end
end
