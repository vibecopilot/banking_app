class CreateRooms < ActiveRecord::Migration[5.1]
  def change
    create_table :rooms do |t|
      t.string :name, null: false
      t.string :room_number, null: false
      t.text :description
      t.string :room_type
      t.decimal :price_per_night, precision: 10, scale: 2, null: false
      t.decimal :tax_percentage, precision: 5, scale: 2, default: 0.0
      t.integer :max_adults, default: 2
      t.integer :max_children, default: 0
      t.integer :total_capacity
      t.decimal :room_size, precision: 8, scale: 2
      t.string :bed_type
      t.text :amenities
      t.text :special_features
      t.boolean :is_active, default: true
      t.boolean :is_available, default: true
      t.references :site, null: false, foreign_key: true
      t.timestamps
    end

    add_index :rooms, [:site_id, :is_active]
    add_index :rooms, [:site_id, :room_number], unique: true
    add_index :rooms, [:site_id, :room_type]
  end
end
