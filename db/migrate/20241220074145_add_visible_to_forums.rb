class AddVisibleToForums < ActiveRecord::Migration[5.1]
  def change
    add_column :forums, :visible, :boolean, default: true, null: false
  end
end
