class CreateStatusRestaurants < ActiveRecord::Migration[5.1]
  def change
    create_table :status_restaurants do |t|
      t.string :status
      t.string :display_name
      t.boolean :fixed_state
      t.integer :order
      t.string :color

      t.timestamps
    end
  end
end
