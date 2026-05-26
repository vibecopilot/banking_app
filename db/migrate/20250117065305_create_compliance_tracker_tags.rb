class CreateComplianceTrackerTags < ActiveRecord::Migration[5.1]
  def change
    create_table :compliance_tracker_tags do |t|
      t.integer :compliance_tracker_id
      t.datetime :submitted_on
      t.integer :submitted_by_id
      t.integer :compliance_tag_id
      t.text :observation
      t.text :recommendtion
      t.text :comment
      t.integer :compliance_tag_task_id

      t.timestamps
    end
  end
end
