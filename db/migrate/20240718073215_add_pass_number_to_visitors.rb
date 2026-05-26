class AddPassNumberToVisitors < ActiveRecord::Migration[5.1]
  def change
    add_column :visitors, :pass_number, :string
  end
end
