class AddFieldsToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :department_id, :integer
    add_column :users, :manager_id, :integer
    add_column :users, :about_me, :text
    add_column :users, :position, :string
    add_column :users, :connection, :string

  end
end
