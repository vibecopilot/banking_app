class AddamenityColumnToAmenityNotification < ActiveRecord::Migration[5.1]
  def change
    add_column :amenity_notifications, :amenity_id, :string
  end
end
