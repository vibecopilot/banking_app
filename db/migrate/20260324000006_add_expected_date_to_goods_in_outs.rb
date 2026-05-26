class AddExpectedDateToGoodsInOuts < ActiveRecord::Migration[5.1]
  def change
    add_column :goods_in_outs, :expected_date, :datetime
  end
end
