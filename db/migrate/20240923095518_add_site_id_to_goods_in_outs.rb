class AddSiteIdToGoodsInOuts < ActiveRecord::Migration[5.1]
  def change
    add_column :goods_in_outs, :site_id, :integer
  end
end
