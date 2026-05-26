class CreateTmpChecklists < ActiveRecord::Migration[5.1]
  def change
    create_table :tmp_checklists do |t|
      t.integer :site_id
      t.string :frequency
      t.integer :user_id
      t.string :tmp_name
      t.string :occurs
      t.string :ctype
      t.integer :patrolling_id
      t.boolean :weightage_enabled

      t.timestamps
    end
  end
end
