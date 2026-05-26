class CreatePermitSafetyEquipments < ActiveRecord::Migration[5.1]
  def change
    create_table :permit_safety_equipments do |t|
      t.string :safety_equipment_name
      t.integer :permit_type_id
      t.integer :activity_id
      t.integer :sub_activity_id
      t.integer :hazard_category_id
      t.integer :permit_risk_id

      t.timestamps
    end
  end
end
