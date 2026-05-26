class ChangeColumnTypeToIncident < ActiveRecord::Migration[5.1]
  def change
    change_column :incidents, :primary_incident_category, :string
    change_column :incidents, :secondary_incident_category, :string
  end
end
