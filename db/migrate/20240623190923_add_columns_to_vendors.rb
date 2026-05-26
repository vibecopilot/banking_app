class AddColumnsToVendors < ActiveRecord::Migration[5.1]
  def change
    add_column :vendors, :first_name, :string
    add_column :vendors, :last_name, :string
    add_column :vendors, :secondary_mobile, :string
    add_column :vendors, :secondary_email, :string
    add_column :vendors, :gstin_number, :string
    add_column :vendors, :pan_number, :string
    add_column :vendors, :address, :text
    add_column :vendors, :active, :boolean, default: true
    add_column :vendors, :country, :string
    add_column :vendors, :state, :string
    add_column :vendors, :city, :string
    add_column :vendors, :pincode, :string
    add_column :vendors, :address2, :text
    add_column :vendors, :account_name, :string
    add_column :vendors, :account_number, :string
    add_column :vendors, :bank_branch_name, :string
    add_column :vendors, :ifsc_code, :string
    add_column :vendors, :website_url, :string    
    add_column :vendors, :district, :string
  end
end
