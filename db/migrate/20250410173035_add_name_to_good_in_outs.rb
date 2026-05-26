class AddNameToGoodInOuts < ActiveRecord::Migration[5.1]
  def change
    add_column :goods_in_outs, :name, :string
  end
end
