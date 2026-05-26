class ChangeActiveToBooleanInAmenities < ActiveRecord::Migration[5.1]
  def change
    change_column :amenities, :active, :boolean, using: 'active::boolean', default: true
  end
end
