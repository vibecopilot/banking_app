class CreateChecklistCrons < ActiveRecord::Migration[5.1]
  def change
    create_table :checklist_crons do |t|
      t.integer :checklist_id
      t.string :expression

      t.timestamps
    end
  end
end
