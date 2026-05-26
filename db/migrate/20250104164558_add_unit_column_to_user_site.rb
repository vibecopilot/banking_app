class AddUnitColumnToUserSite < ActiveRecord::Migration[5.1]
  def change
    add_column :user_sites, :unit_id, :integer
    add_column :user_sites, :lives_here, :boolean
    add_column :user_sites, :ownership, :string
    add_column :user_sites, :ownership_type, :string
    add_column :user_sites, :is_approved, :boolean
  end
end
