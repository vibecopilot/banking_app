class AddMemberToAmenity < ActiveRecord::Migration[5.1]
  def change
    add_column :amenities, :member, :boolean
    add_column :amenities, :guest, :boolean
  end
end
