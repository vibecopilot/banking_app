class AddColumnsToIncidents < ActiveRecord::Migration[5.1]
  def change
    add_column :incidents, :primary_incident_sub_category, :string
    add_column :incidents, :primary_incident_sub_sub_category, :string
    add_column :incidents, :secondary_incident_sub_category, :string
    add_column :incidents, :secondary_incident_sub_sub_category, :string
    add_column :incidents, :property_damage, :boolean, default: false
    add_column :incidents, :rca, :string
    add_column :incidents, :primary_root_cause_category, :string
    add_column :incidents, :corrective_action, :text
    add_column :incidents, :preventive_action, :text
    add_column :incidents, :first_aid_provided_employee, :boolean, default: false
    add_column :incidents, :sent_medical_treatment, :boolean, default: false
    add_column :incidents, :support_required, :boolean, default: false
    add_column :incidents, :read_facts_states, :text

  end
end