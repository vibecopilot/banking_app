json.total_count @total_count
json.total_pages @site_assets.respond_to?(:total_pages) ? @site_assets.total_pages : 1
json.current_page @site_assets.current_page
json.site_assets do
json.array! @site_assets, partial: "site_assets/site_asset", as: :site_asset
end


