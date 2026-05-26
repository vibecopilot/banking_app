class AddAdulPriceColumnToAmenity < ActiveRecord::Migration[5.1]
  def change
    add_column :amenities, :is_member_adult, :boolean
    add_column :amenities, :is_member_child, :boolean
    add_column :amenities, :is_guest_adult, :boolean
    add_column :amenities, :is_guest_child, :boolean
    add_column :amenities, :is_tenant_child, :boolean
    add_column :amenities, :is_tenant_adult, :boolean
  end
end
