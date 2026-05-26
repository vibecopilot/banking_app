class AddTenantToAmenityBooking < ActiveRecord::Migration[5.1]
  def change
    add_column :amenity_bookings, :no_of_tenants, :integer
    add_column :amenity_bookings, :tenant_adult, :integer
    add_column :amenity_bookings, :tenant_child, :integer
  end
end
