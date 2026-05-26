class CreateProjects < ActiveRecord::Migration[5.1]
  def change
    create_table :projects do |t|
      t.integer :user_id
      t.string :name
      t.boolean :active

      t.timestamps
    end
  end
end
