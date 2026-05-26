json.extract! group_member, :id, :group_id, :site_id, :company_id, :created_at, :updated_at,:user_id
json.url group_member_url(group_member, format: :json)
# binding.pry
json.user_name group_member.user.try(:full_name)

