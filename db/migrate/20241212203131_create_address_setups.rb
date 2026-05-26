class CreateAddressSetups < ActiveRecord::Migration[5.1]
  def change
    create_table :address_setups do |t|
      t.string :title
      t.text :address
      t.integer :building_id
      t.string :state
      t.string :phone_number
      t.string :fax_number
      t.string :email_address
      t.string :registration_no
      t.string :pan_number
      t.string :cheque_in_favour_of
      t.string :gst_number

      t.timestamps
    end
  end
end
