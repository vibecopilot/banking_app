class AddInsuredByIdToIncident < ActiveRecord::Migration[5.1]
  def change
    add_column :incidents, :insured_by_id, :integer
  end
end
