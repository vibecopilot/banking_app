class CreateTasks < ActiveRecord::Migration[5.1]
  def change
    create_table :tasks do |t|
      t.integer :project_id
      t.string :name
      t.date :tat
      t.integer :priority
      t.integer :status
      t.boolean :active

      t.timestamps
    end
  end
end
