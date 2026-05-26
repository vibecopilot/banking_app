class AddUserCoumnToPet < ActiveRecord::Migration[5.1]
  def change
    add_column :pets, :user_id, :integer
  end
end
