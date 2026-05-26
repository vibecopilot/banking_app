class RemoveInsuredByIdToIncident < ActiveRecord::Migration[5.1]
  def change
    remove_column :incidents, :insured_by_id, :integer
    add_column :incidents, :insured_by, :string
    add_column :incidents, :first_aid_attendant, :string
    add_column :incidents, :treatment_facility, :string
    add_column :incidents, :attending_physician, :string
    add_column :incidents, :property_damage_category, :string
    add_column :incidents, :damage_coverd_under_insurance, :boolean
    add_column :incidents, :read_fact_state, :boolean
  end
end
