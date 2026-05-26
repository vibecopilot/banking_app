json.total_count @fitout_requests.total_count
json.total_pages @fitout_requests.total_pages
json.current_page @fitout_requests.current_page

josn.fitout_requests do
	json.array! @fitout_requests, partial: "fitout_requests/index", as: :fitout_request
end