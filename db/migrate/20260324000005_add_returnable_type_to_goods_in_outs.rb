class AddReturnableTypeToGoodsInOuts < ActiveRecord::Migration[5.1]
  def change
    add_column :goods_in_outs, :returnable_type, :string
  end
end
