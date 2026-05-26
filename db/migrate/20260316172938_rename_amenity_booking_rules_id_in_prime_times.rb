class RenameAmenityBookingRulesIdInPrimeTimes < ActiveRecord::Migration[5.2]
  def change
    rename_column :prime_times, :amenity_booking_rules_id, :amenity_booking_rule_id
  end
end