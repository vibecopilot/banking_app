class AddNewColumnToTodoList < ActiveRecord::Migration[5.1]
  def change
     add_column :todo_lists, :assigned_to, :integer
     add_column :todo_lists, :task_type, :string
     add_column :todo_lists, :urgent, :boolean
     add_column :todo_lists, :repeat, :boolean
     add_column :todo_lists, :to_from, :date
     add_column :todo_lists, :to_date, :date
     add_column :todo_lists, :time, :integer
    add_column :todo_lists, :working_days, :json
  end
end
