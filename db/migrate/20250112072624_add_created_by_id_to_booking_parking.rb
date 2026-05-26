class AddCreatedByIdToBookingParking < ActiveRecord::Migration[5.1]
  def change
    add_column :booking_parkings, :creatde_by_id, :integer
  end
end
