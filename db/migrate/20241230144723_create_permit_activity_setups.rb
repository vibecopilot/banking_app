class CreatePermitActivitySetups < ActiveRecord::Migration[5.1]
  def change
    create_table :permit_activity_setups do |t|
      t.integer :permit_type_id
      t.string :name
      t.integer :site_id

      t.timestamps
    end
  end
end
