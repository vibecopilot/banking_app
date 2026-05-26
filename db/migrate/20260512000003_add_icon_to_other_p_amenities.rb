class AddIconToOtherPAmenities < ActiveRecord::Migration[5.1]
  def change
    add_column :other_p_amenities, :icon, :string
  end
end
