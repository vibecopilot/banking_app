class CreateGoodsItems < ActiveRecord::Migration[5.1]
  def change
    create_table :goods_items do |t|
      t.references :goods_in_out, foreign_key: true
      t.string :item_name
      t.integer :quantity
      t.string :unit
      t.text :description

      t.timestamps
    end
  end
end
