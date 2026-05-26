class AddProductColumnToSite < ActiveRecord::Migration[5.2]
  def change
    add_column :sites, :selected_product, :string
  end
end
