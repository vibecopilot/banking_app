class CreateSeats < ActiveRecord::Migration[5.1]
  def change
    create_table :seats do |t|
      t.integer :buiding_id
      t.integer :floor_id
      t.integer :unit_id
      t.string :seat
      t.integer :no
      t.integer :category_id
      t.integer :site_id

      t.timestamps
    end
  end
end
