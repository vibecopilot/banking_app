class CreateCapas < ActiveRecord::Migration[5.2]
  def change
    create_table :capas do |t|
      t.integer :complaint_id
      t.string :title
      t.text :root_cause
      t.text :corrective_action
      t.text :preventive_action
      t.text :effectiveness
      t.integer :owner_id
      t.date :due_date
      t.string :status, default: "open"
      t.integer :site_id
      t.integer :created_by
      t.timestamps
    end
    add_index :capas, :complaint_id
    add_index :capas, :site_id
    add_index :capas, :status
  end
end
