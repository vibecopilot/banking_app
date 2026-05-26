json.extract! generic_sub_info, :id, :generic_info_id, :name, :created_at, :updated_at
json.generic_info_name generic_sub_info.generic_info&.name
json.generic_info_type generic_sub_info.generic_info&.info_type

@generic_sub_files = generic_sub_info&.generic_sub_files
json.generic_sub_files do
  json.array!(@generic_sub_files) do |doc|
    json.extract! doc, :id, :relation, :relation_id
    json.document doc.document_url
  end
end

json.url generic_info_generic_sub_info_url(generic_sub_info.generic_info, generic_sub_info, format: :json)