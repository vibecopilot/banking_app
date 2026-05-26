class AddWhoToIncidentInjury < ActiveRecord::Migration[5.1]
  def change
    add_column :incident_injuries, :who_got_injured, :string
  end
end
