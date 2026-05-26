json.extract! group, :id, :group_name, :group_type, :group_admin, :group_roles, :group_permissions, :group_activities, :add_members, :group_description, :created_by_id, :created_at, :updated_at
json.admin_name User.find_by(id: group.group_admin)&.slice(:firstname, :lastname)
json.member_name User.find_by(id: group.add_members)&.slice(:firstname, :lastname)
json.url group_url(group, format: :json)
@attachments = Attachfile.where("relation = 'UserGroup' AND relation_id = ?", group.id)
json.cover_image do
  json.array!(@attachments) do |doc|
    json.extract! doc, :id, :relation, :relation_id
    json.document_url doc.document_url
  end
end
json.group_members do 
  json.array! group.group_members, partial: "group_members/group_member", as: :group_member
end
