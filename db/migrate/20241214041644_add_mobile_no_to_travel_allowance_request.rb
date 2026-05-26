class AddMobileNoToTravelAllowanceRequest < ActiveRecord::Migration[5.1]
  def change
    add_column :travel_allowance_requests, :mobile_no, :string
  end
end
