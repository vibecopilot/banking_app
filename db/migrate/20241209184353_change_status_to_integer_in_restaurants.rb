class ChangeStatusToIntegerInRestaurants < ActiveRecord::Migration[5.1]
    def up
    change_column :status_restaurants, :status, :integer
  end

  def down
    change_column :status_restaurants, :status, :string  
  end
end
