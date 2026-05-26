class CreateAmcContacts < ActiveRecord::Migration[5.1]
  def change
    create_table :amc_contacts do |t|
      t.integer :asset_amc_id
      t.string :name
      t.string :phone
      t.string :email
      t.string :designation

      t.timestamps
    end
  end
end
