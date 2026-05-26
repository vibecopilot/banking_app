class CreateStaffUnits < ActiveRecord::Migration[5.1]
  def change
    create_table :staff_units do |t|
      t.references :staff, foreign_key: true
      t.references :unit, foreign_key: true

      t.timestamps
    end
  end
end
