json.total_count @surveys.total_entries
json.total_pages @surveys.total_pages
json.current_page @surveys.current_page

json.survey do
	json.array! @surveys, partial: "surveys/survey", as: :survey
end