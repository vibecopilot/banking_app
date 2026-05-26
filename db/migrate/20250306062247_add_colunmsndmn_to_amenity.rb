class AddColunmsndmnToAmenity < ActiveRecord::Migration[5.1]
  def change
    add_column :amenities, :non_member, :boolean
    add_column :amenities, :non_member_price_adult, :float
    add_column :amenities, :non_member_price_child, :float
    add_column :amenities, :complimentary, :boolean
    add_column :amenities, :postpaid, :boolean
    add_column :amenities, :prepaid, :boolean
    add_column :amenities, :gst, :float
    add_column :amenities, :consecutive_slot_allowed, :boolean
  end
end
