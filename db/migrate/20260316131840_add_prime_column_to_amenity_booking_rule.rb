class AddPrimeColumnToAmenityBookingRule < ActiveRecord::Migration[5.2]
  def change
    add_column :amenity_booking_rules, :facility_can_be_booked, :boolean
    add_column :amenity_booking_rules, :times_per_day, :integer
    add_column :amenity_booking_rules, :period_type, :string
  end
end
