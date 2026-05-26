class AddStatusColumnToEvent < ActiveRecord::Migration[5.1]
  def change
      add_column :events, :status, :string, default: 'upcoming'
  end
end
