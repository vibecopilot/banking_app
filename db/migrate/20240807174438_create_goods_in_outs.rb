class CreateGoodsInOuts < ActiveRecord::Migration[5.1]
  def change
    create_table :goods_in_outs do |t|
      t.integer :visitor_id
      t.integer :no_of_goods
      t.string :description
      t.string :ward_type
      t.string :vehicle_no
      t.string :person_name
      t.datetime :goods_in_time
      t.datetime :goods_out_time
      t.integer :staff_id
      t.integer :created_by_id

      t.timestamps
    end
  end
end
