class AddDeleteCoumnToUserRefferal < ActiveRecord::Migration[5.1]
  def change
    add_column :user_refferals, :deleted, :boolean, default: false
  end
end
