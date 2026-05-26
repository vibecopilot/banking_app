class AddaccountColumnToSite < ActiveRecord::Migration[5.1]
  def change
    add_column :sites, :account_id, :string
    add_index :sites, :account_id, unique: true
  end
end
