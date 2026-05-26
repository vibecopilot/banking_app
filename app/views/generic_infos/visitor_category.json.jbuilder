json.visitor_categories @categories do |cat|
  json.name cat[:name]
  json.count cat[:count]
end

json.total_count @categories.size
