class ChangeLotusTok < ActiveRecord::Migration[5.2]
  def change
    change_column :users, :lotus_token, :text
  end
end
