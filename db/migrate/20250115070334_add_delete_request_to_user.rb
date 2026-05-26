class AddDeleteRequestToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :delete_request, :boolean
  end
end
