class CreateApprovals < ActiveRecord::Migration[5.1]
  def change
    create_table :approvals do |t|
      t.integer :site_id
      t.integer :user_id
      t.integer :level_id
      t.date :start_date
      t.date :end_date
      t.integer :resource_id
      t.string :resource_type
      t.text :comments
      t.integer :approved_by_id
      t.string :approver_comments

      t.timestamps
    end
  end
end
