json.helpdesk_sub_categories @helpdesk_sub_categories do |sub_category|
  json.id sub_category.id
  json.name sub_category.name
  json.active sub_category.active
  json.helpdesk_category_id sub_category.helpdesk_category_id
end