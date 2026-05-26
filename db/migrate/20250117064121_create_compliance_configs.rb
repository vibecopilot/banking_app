class CreateComplianceConfigs < ActiveRecord::Migration[5.1]
  def change
    create_table :compliance_configs do |t|
      t.string :name
      t.string :frequency
      t.integer :due_in_days
      t.string :priority
      t.text :description
      t.integer :assign_to_id
      t.integer :reviewer_id
      t.datetime :start_date
      t.datetime :end_date
      t.integer :site_id

      t.timestamps
    end
  end
end
