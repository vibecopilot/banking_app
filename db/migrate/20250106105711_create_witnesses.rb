class CreateWitnesses < ActiveRecord::Migration[5.1]
  def change
    create_table :witnesses do |t|
      t.string :name
      t.string :mobile
      t.references :incident, foreign_key: true

      t.timestamps
    end
  end
end
