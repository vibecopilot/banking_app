class CreateAminities < ActiveRecord::Migration[5.1]
  def change
    create_table :aminities do |t|
      t.string :name
      t.integer :site_id
      t.decimal :cost, precision: 8, scale: 2

      t.timestamps
    end
  end
end
