class AddDistanceToSite < ActiveRecord::Migration[5.1]
  def change
    add_column :sites, :radius, :integer
  end
end
