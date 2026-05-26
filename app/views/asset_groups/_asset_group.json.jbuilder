json.extract! asset_group, :id, :name, :description, :created_at, :updated_at, :group_for
json.url asset_group_url(asset_group, format: :json)
