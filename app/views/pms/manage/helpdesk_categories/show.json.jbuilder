json.extract! @helpdesk_category, :id, :name, :society_id, :created_at, :updated_at
json.sub_categories @helpdesk_category.helpdesk_sub_categories do |sub_category|
  json.extract! sub_category, :id, :name
end