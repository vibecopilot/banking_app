# app/views/pms/manage/helpdesk_categories/get_sub_categories.json.jbuilder

json.sub_categories @sub_categories do |sub_category|
  json.id sub_category.id
  json.helpdesk_category_name sub_category.helpdesk_category.name
  json.helpdesk_category_id sub_category.helpdesk_category_id
  json.name sub_category.name
  json.position sub_category.position
  json.active sub_category.active
  json.created_at sub_category.created_at
  json.updated_at sub_category.updated_at
  json.issue_type_id sub_category.issue_type_id
  json.helpdesk_text sub_category.helpdesk_text
end
