class CreateAudits < ActiveRecord::Migration[5.1]
  def change
    create_table :audits do |t|
      t.string :audit_for
      t.string :activity_name
      t.text :description
      t.boolean :allow_observations
      t.string :checklist_type
      t.integer :asset_name
      t.integer :service_name
      t.integer :vendor_name
      t.string :training_name
      t.integer :assign_to
      t.string :scan_type
      t.integer :plan_duration
      t.string :priority
      t.string :email_trigger_rule
      t.integer :supervisors
      t.integer :category
      t.string :look_overdue_task
      t.string :frequency
      t.datetime :start_from
      t.datetime :end_at
      t.integer :select_supplier
      t.integer :created_by_id

      t.timestamps
    end
  end
end
