json.current_page @items.current_page
json.total_pages @items.total_pages
json.total_count @items.total_count


json.items do
json.array! @items, partial: "items/item", as: :item
end