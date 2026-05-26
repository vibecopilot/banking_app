class CreatePermitRisks < ActiveRecord::Migration[5.1]
  def change
    create_table :permit_risks do |t|
      t.integer :permit_type_id
      t.integer :activity_id
      t.integer :sub_activity_id
      t.integer :hazard_category_id
      t.text :risk_description

      t.timestamps
    end
  end
end
