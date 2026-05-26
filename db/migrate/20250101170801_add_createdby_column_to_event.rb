class AddCreatedbyColumnToEvent < ActiveRecord::Migration[5.1]
  def change
    add_column :events, :created_by, :integer
  end
end
