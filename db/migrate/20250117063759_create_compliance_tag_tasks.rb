class CreateComplianceTagTasks < ActiveRecord::Migration[5.1]
  def change
    create_table :compliance_tag_tasks do |t|
      t.string :name
      t.boolean :weightage
      t.integer :compliance_tag_id

      t.timestamps
    end
  end
end
