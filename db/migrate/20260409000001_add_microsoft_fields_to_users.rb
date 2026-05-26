class AddMicrosoftFieldsToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :microsoft_uid,                        :string
    add_column :users, :encrypted_microsoft_access_token,     :text
    add_column :users, :encrypted_microsoft_access_token_iv,  :string
    add_column :users, :encrypted_microsoft_refresh_token,    :text
    add_column :users, :encrypted_microsoft_refresh_token_iv, :string
    add_column :users, :microsoft_token_expires_at,           :datetime

    add_index :users, :microsoft_uid, unique: true, name: 'index_users_on_microsoft_uid'
  end
end
