class AddDateTimeToUserRefferal < ActiveRecord::Migration[5.1]
  def change
    add_column :user_refferals, :date_time, :datetime
  end
end
