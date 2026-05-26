class CreateCostOfIncidents < ActiveRecord::Migration[5.1]
  def change
    create_table :cost_of_incidents do |t|
      t.decimal :equipment_property_cost
      t.decimal :production_loss
      t.decimal :treatment_cost
      t.decimal :absenteeism_cost
      t.decimal :other_cost
      t.decimal :total_cost
      t.references :incident, foreign_key: true

      t.timestamps
    end
  end
end
