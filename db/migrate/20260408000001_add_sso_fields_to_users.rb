class AddSsoFieldsToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :sso_uid, :string
    add_column :users, :sso_provider, :string
    add_index :users, [:sso_uid, :sso_provider], unique: true, name: 'index_users_on_sso_uid_and_provider'
  end
end
