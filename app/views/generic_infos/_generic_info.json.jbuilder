json.extract! generic_info, :id, :name, :company_id, :site_id, :info_type, :created_at, :updated_at,:time
json.url generic_info_url(generic_info, format: :json)
@generic_sub_infos = generic_info.generic_sub_infos

json.generic_sub_infos do
  json.array! @generic_sub_infos do |sub_info|
    json.partial! "generic_sub_infos/generic_sub_info", generic_sub_info: sub_info
  end
end