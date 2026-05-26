json.total_count @activities.total_entries
json.total_pages @activities.respond_to?(:total_pages) ? @activities.total_pages : 1
json.current_page @activities.current_page
puts "count of activities are more than 100" if @activities.count > 100
json.activities @activities, partial: "activities/activity", as: :activity
json.loi_details @loi_details || [], partial: "loi_details/loi_detail", as: :loi_detail