class CreateIncidentInjuries < ActiveRecord::Migration[5.1]
  def change
    create_table :incident_injuries do |t|
      t.string :injury_type
      t.integer :injury_number
      t.integer :incident_id
      t.integer :lost_time
      t.integer :who_got_injured_id
      t.string :name
      t.string :company_name
      t.string :mobile

      t.timestamps
    end
  end
end
