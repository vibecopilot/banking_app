class CreateParkingPolicies < ActiveRecord::Migration[5.1]
  def change
    create_table :parking_policies do |t|
      t.string :who_can_park
      t.string :max_vechille_per_flat
      t.string :allowed_vehicle_type
      t.string :type_of_reservation
      t.string :payment_type
      t.string :billing_frequency
      t.boolean :ev_charging_available
      t.string :charging_type
      t.string :ev_charge_location
      t.string :ev_charge_fee
      t.string :who_Can_access
      t.boolean :visitor_parking_allowed
      t.text :terms_and_condition

      t.timestamps
    end
  end
end
