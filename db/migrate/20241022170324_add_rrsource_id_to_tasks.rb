class AddRrsourceIdToTasks < ActiveRecord::Migration[5.1]
  def change
    add_column :tasks, :resource_id, :integer
    add_column :tasks, :resource_type, :string
  end
end
