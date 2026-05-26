json.staff_categories @categories do |cat|
  json.id cat.id
  json.name cat.name

  json.staffs_count Staff.where(
    work_type: cat.name,
    site_id: params[:site_id] || @user.current_site_id
  ).count
end

json.total_count @categories.count