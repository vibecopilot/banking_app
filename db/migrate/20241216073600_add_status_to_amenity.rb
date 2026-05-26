class AddStatusToAmenity < ActiveRecord::Migration[5.1]
  def change
    add_column :amenities, :status, :string, default: 'pending'
  end
end
