class AddMobileToTransportationAllowanceRequest < ActiveRecord::Migration[5.1]
  def change
    add_column :transportation_allowance_requests, :mobile_no, :string
  end
end
