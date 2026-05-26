class Addbuildingidtousersite < ActiveRecord::Migration[5.1]
  def change
    add_column :user_sites, :build_id, :integer
  end
end
