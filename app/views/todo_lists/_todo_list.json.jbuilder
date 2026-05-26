json.extract! todo_list, :title, :status, :relation_id, :relation, :site_id, :start_at, :end_at, :assigned_to, :task_type, :urgent, :repeat, :to_from, :to_date, :time, :working_days,:due_date, :task_description, :dependent_task_ids
json.url todo_list_url(todo_list, format: :json)

@docs = Attachfile.where("relation = 'TodoList' and relation_id = ?", todo_list.id)
json.documents do
      json.array!(@docs) do |doc|
        json.extract! doc, :id, :relation, :relation_id
        json.document doc.document_url
      end
end