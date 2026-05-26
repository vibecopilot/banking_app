class AddNoGoodsCoulumnToVisitor < ActiveRecord::Migration[5.2]
  def change
    add_column :visitors, :no_of_goods, :integer
  end
end
