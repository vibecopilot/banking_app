class AddshareColumnToPoll < ActiveRecord::Migration[5.1]
  def change
    add_column :polls, :shared, :string
  end
end
