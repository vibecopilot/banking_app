class AddGstNoToAmenity < ActiveRecord::Migration[5.1]
  def change
    add_column :amenities, :gst_no, :string
  end
end
