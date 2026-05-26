class AddVerifiedToVisitors < ActiveRecord::Migration[5.1]
  def change
    add_column :visitors, :verified, :boolean, default: false
  end
end
