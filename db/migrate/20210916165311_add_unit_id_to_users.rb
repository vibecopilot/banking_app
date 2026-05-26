class AddUnitIdToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :mobile, :string
    add_column :users, :unit_id, :integer
    add_column :users, :current_site_id, :integer
  end
end
