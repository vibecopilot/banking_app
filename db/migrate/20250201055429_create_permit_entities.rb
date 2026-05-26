class CreatePermitEntities < ActiveRecord::Migration[5.1]
  def change
    create_table :permit_entities do |t|
      t.string :name
      t.integer :permit_id
      t.boolean :active

      t.timestamps
    end
  end
end
