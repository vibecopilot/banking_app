json.current_page @inventories.current_page
json.total_pages @inventories.total_pages
json.total_count @inventories.total_count

json.inventories do
json.array! @inventories, partial: "inventories/inventory", as: :inventory
end