class CreateGates < ActiveRecord::Migration[5.1]
  def change
    create_table :gates do |t|
      t.string :name
      t.integer :site_id
      t.integer :user_id
      t.integer :created_by_id

      t.timestamps
    end
  end
end
