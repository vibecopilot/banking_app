class AddTypeCoumnToUserRefferal < ActiveRecord::Migration[5.1]
  def change
    add_column :user_refferals, :refferal_type, :string
  end
end
