class CreateSubmissions < ActiveRecord::Migration[5.1]
  def change
    create_table :submissions do |t|
      t.integer :asset_id
      t.integer :checklist_id
      t.integer :activity_id
      t.integer :question_id
      t.string :value
      t.text :comment
      t.integer :user_id

      t.timestamps
    end
  end
end
