json.total_user User.where(current_site_id: @user.current_site_id).count
current_site_id = @user.current_site_id

# All users of current site
current_site_users = User
  .joins(:user_sites)
  .where(user_sites: { site_id: current_site_id })  

# TOTAL downloads
total_user_downloads = UserDevice
  .where(user_id: current_site_users.select(:id))
  .count

json.total_user_downloads total_user_downloads

# TENANT downloads
total_tenant_downloads = UserDevice
  .where(user_id: current_site_users
    .where(user_sites: { ownership: "tenant" })
    .select(:id)
  ).count

json.total_tenant_downloads total_tenant_downloads
# OWNER downloads
total_owner_downloads = UserDevice
  .where(user_id: current_site_users
    .where(user_sites: { ownership: "owner" })
    .select(:id)
  ).count

json.total_owner_downloads total_owner_downloads  

json.users @users.where(current_site_id: @user.current_site_id) do |user|
  json.id user.id
  json.firstname user.firstname
  json.lastname user.lastname
  json.email user.email
  json.mobile user.mobile
  json.api_key user.api_key
end
