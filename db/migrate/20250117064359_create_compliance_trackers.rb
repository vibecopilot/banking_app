class CreateComplianceTrackers < ActiveRecord::Migration[5.1]
  def change
    create_table :compliance_trackers do |t|
      t.integer :compliance_config_id
      t.string :status
      t.datetime :submitted_on
      t.integer :submitted_by_id
      t.integer :site_id

      t.timestamps
    end
  end
end
