class BackfillServiceBookingsUnitConfiguration < ActiveRecord::Migration[5.1]
  def up
    # Backfill unit_configuration_id for existing service_bookings
    ServiceBooking.where(unit_configuration_id: nil).find_each do |booking|
      if booking.unit&.unit_configuration_id
        booking.update_column(:unit_configuration_id, booking.unit.unit_configuration_id)
      end
    end
  end

  def down
    # No-op for down migration
  end
end
