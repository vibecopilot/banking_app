class CreateMenus < ActiveRecord::Migration[5.1]
  def change
    create_table :menus do |t|
      t.string :name
      t.integer :site_id
      t.integer :generic_info_id
      t.text :description
      t.integer :hotel_id
      t.decimal :price, precision: 8, scale: 2

      t.timestamps
    end
  end
end
