json.total_entries @asset_amcs.total_entries
json.current_page @asset_amcs.current_page
json.total_pages @asset_amcs.total_pages

json.asset_amcs do
json.array! @asset_amcs, partial: "asset_amcs/asset_amc", as: :asset_amc
end
