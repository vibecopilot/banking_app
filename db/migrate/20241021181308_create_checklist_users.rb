class CreateChecklistUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :checklist_users do |t|
      t.integer :resource_id
      t.integer :checklist_id
      t.string :resource_type
      t.integer :user_id

      t.timestamps
    end
  end
end
