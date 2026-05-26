class AddpayonfacilityColumnToAmenity < ActiveRecord::Migration[5.1]
  def change
    add_column :amenities, :sgst, :float
    add_column :amenities, :pay_on_facility, :boolean
  end
end