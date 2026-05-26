class AdDueDateColumnToTodoList < ActiveRecord::Migration[5.1]
  def change
    add_column :todo_lists, :due_date, :datetime
    add_column :todo_lists, :task_description, :text
    add_column :todo_lists, :dependent_task_ids, :json
  end
end
