class AddNewColumnToAmenity < ActiveRecord::Migration[5.1]
  def change
    add_column :amenities, :is_hotel, :boolean
    add_column :amenities, :no_of_days, :string
  end
end
