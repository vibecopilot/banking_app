class RemoveIconFromOtherPAmenities < ActiveRecord::Migration[5.1]
  def change
    remove_column :other_p_amenities, :icon, :string
  end
end
