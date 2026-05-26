class AddBankDetailsToAddressSetups < ActiveRecord::Migration[5.1]
  def change
    add_column :address_setups, :account_number, :string
    add_column :address_setups, :account_type, :string
    add_column :address_setups, :ifsc_code, :string
    add_column :address_setups, :account_name, :string
    add_column :address_setups, :bank_branch_name, :string
  end
end
