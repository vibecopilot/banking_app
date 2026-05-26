json.extract! ticket, :id, :site_id, :category_id, :sub_category_id, :status, :description, :created_by_id, :assigned_to_id, :total_cost, :tm_id, :created_at, :updated_at
json.url ticket_url(ticket, format: :json)
