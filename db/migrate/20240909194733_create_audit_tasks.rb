class CreateAuditTasks < ActiveRecord::Migration[5.1]
  def change
    create_table :audit_tasks do |t|
      t.integer :group
      t.integer :sub_group
      t.string :task
      t.string :input_type
      t.boolean :mandatory
      t.boolean :reading
      t.boolean :help_text
      t.string :weightage
      t.boolean :rating
      t.integer :audit_id
      t.integer :created_by_id

      t.timestamps
    end
  end
end
