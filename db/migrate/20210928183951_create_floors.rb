class CreateFloors < ActiveRecord::Migration[5.1]
  def change
    create_table :floors do |t|
      t.string :name
      t.integer :building_id
      t.integer :site_id

      t.timestamps
    end
  end
end
