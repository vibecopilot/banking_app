class AddMglColumnToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :moving_date, :datetime
    add_column :users, :profession, :string
    add_column :users, :mgl_customer_number, :string
    add_column :users, :adani_electricity_account_no, :string
    add_column :users, :net_provider_name, :string
    add_column :users, :net_provider_id, :string
  end
end
