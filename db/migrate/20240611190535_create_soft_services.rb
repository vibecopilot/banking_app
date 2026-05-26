class CreateSoftServices < ActiveRecord::Migration[5.1]
  def change
    create_table :soft_services do |t|
      t.integer :site_id
      t.integer :building_id
      t.integer :floor_id
      t.integer :unit_id
      t.string :name
      t.integer :user_id

      t.timestamps
    end
  end
end
