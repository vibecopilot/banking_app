class AddTypeOfFacilityColumntToAmenity < ActiveRecord::Migration[5.1]
  def change
    add_column :amenities, :type_of_facility, :string
  end
end
