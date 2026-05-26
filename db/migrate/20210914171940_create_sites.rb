class CreateSites < ActiveRecord::Migration[5.1]
  def change
    create_table :sites do |t|
      t.string :name
      t.string :region
      t.boolean :active

      t.timestamps
    end
  end
end
