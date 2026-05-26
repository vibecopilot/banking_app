class CreateStandardUnits < ActiveRecord::Migration[5.1]
  def change
    create_table :standard_units do |t|
      t.string :unit_name
      t.string :convention
      t.integer :company_id

      t.timestamps
    end
  end
end
