class AddLadLongRequiredToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :lad_long_required, :boolean
  end
end
