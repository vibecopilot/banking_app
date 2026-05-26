class AddFloorCoulmnToUserSite < ActiveRecord::Migration[5.1]
  def change
    add_column :user_sites, :floor_id, :integer
  end
end
