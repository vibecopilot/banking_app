class CreateAddresses < ActiveRecord::Migration[5.1]
  def change
    create_table :addresses do |t|
      t.string :address_title
      t.string :building_name
      t.string :street_name
      t.string :email_address
      t.string :state
      t.string :city
      t.integer :phone_number
      t.integer :pin_code

      t.timestamps
    end
  end
end
