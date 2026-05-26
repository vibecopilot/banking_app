json.array! @generic_infos do |generic_info|
  json.extract! generic_info, :id, :company_id, :info_type, :created_at, :updated_at

  json.user User.find_by(id: generic_info.try(:name).to_i).try(:full_name)
  json.site Site.find_by(id: generic_info.try(:site_id)).try(:name)
end
