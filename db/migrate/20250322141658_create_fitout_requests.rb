class CreateFitoutRequests < ActiveRecord::Migration[5.1]
  def change
    create_table :fitout_requests do |t|
      t.integer :building_id
      t.integer :floor_id
      t.integer :unit_id
      t.integer :user_id
      t.text :description
      t.datetime :selected_date
      t.integer :supplier_id

      t.timestamps
    end
  end
end
