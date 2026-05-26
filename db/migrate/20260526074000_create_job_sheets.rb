class CreateJobSheets < ActiveRecord::Migration[5.2]
  def change
    create_table :job_sheets do |t|
      t.integer :ticket_id
      t.string :technician
      t.datetime :scheduled_at
      t.datetime :check_in_at
      t.datetime :check_out_at
      t.text :work_notes
      t.text :materials
      t.string :status, default: "scheduled"
      t.text :signature
      t.integer :site_id
      t.integer :created_by
      t.timestamps
    end
    add_index :job_sheets, :ticket_id
    add_index :job_sheets, :site_id
    add_index :job_sheets, :status
  end
end
