class AddFieldsLotusToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :start_date, :date
    add_column :users, :end_date, :date
    add_column :users, :lotus_token, :string
  end
end
