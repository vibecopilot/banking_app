class AddSharedToEvent < ActiveRecord::Migration[5.1]
  def change
    add_column :events, :shared, :string
  end
end
