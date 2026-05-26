class AddNoOfPeopleToRegisteredVehicleVisits < ActiveRecord::Migration[5.1]
  def change
    add_column :registered_vehicle_visits, :no_of_people, :integer
  end
end
