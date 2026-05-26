class CreateTodoLists < ActiveRecord::Migration[5.1]
  def change
    create_table :todo_lists do |t|
      t.string :title
      t.string :status
      t.integer :relation_id
      t.string :relation
      t.integer :site_id
      t.datetime :start_at
      t.datetime :end_at

      t.timestamps
    end
  end
end
