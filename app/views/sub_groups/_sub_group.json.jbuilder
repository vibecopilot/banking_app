json.extract! sub_group, :id, :group_id, :name, :created_at, :updated_at
group = AssetGroup.find_by(id: sub_group.group_id)
json.group_name group.try(:name)
json.url sub_group_url(sub_group, format: :json)
