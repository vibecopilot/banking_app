class AddMobileNoToCabAndBusRequest < ActiveRecord::Migration[5.1]
  def change
    add_column :cab_and_bus_requests, :mobile_no, :string
  end
end
