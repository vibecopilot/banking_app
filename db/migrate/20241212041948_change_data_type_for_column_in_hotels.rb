  class ChangeDataTypeForColumnInHotels < ActiveRecord::Migration[5.1]
   def up
  #  change_column :flight_requests, :mobile_no, :string
  end

  def down
    change_column :flight_requests, :ticket_confirmation_number, :integer
end
end
