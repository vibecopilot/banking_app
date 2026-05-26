class AddUserIdCoumnToGrnDetail < ActiveRecord::Migration[5.1]
  def change
    add_column :grn_details, :created_by_id, :integer
  end
end
