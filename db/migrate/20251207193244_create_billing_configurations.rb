class CreateBillingConfigurations < ActiveRecord::Migration[5.1]
  def change
    create_table :billing_configurations do |t|
      t.references :site, foreign_key: true
      t.string :company_name
      t.string :company_logo
      t.string :gst_number
      t.string :pan_number
      t.text :address
      t.string :city
      t.string :state
      t.string :pincode
      t.string :phone
      t.string :email
      t.string :website
      t.string :bank_name
      t.string :account_number
      t.string :ifsc_code
      t.string :branch_name
      t.text :terms_and_conditions

      t.timestamps
    end
  end
end
