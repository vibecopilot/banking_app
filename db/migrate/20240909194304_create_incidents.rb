class CreateIncidents < ActiveRecord::Migration[5.1]
  def change
    create_table :incidents do |t|
      t.datetime :time_and_date
      t.integer :primary_incident_category
      t.integer :secondary_incident_category
      t.string :incident_severity
      t.string :incident_level
      t.integer :building_id
      t.string :probability
      t.text :description
      t.integer :created_by_id

      t.timestamps
    end
  end
end
