class AddColumnsToGoodsInOuts < ActiveRecord::Migration[5.1]
  def change
    add_column :goods_in_outs, :item_type, :string
    add_column :goods_in_outs, :item_category, :string
    add_column :goods_in_outs, :mode_of_transport, :string
    add_column :goods_in_outs, :company_name, :string
    add_column :goods_in_outs, :department, :string
    add_column :goods_in_outs, :reporting_time, :datetime
  end
end
