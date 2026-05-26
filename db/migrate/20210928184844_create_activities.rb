class CreateActivities < ActiveRecord::Migration[5.1]
  def change
    create_table :activities do |t|
      t.integer :asset_id
      t.integer :checklist_id
      t.datetime :start_time
      t.datetime :end_time
      t.string :status
      t.integer :assigned_to

      t.timestamps
    end
  end
end
