json.extract! ticket_item, :id, :ticket_id, :item_id, :rate, :item_count, :created_at, :updated_at
json.item_name ticket_item.item&.name