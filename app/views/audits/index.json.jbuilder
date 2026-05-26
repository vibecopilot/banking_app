json.total_count @audits.total_entries
json.current_page @audits.current_page
json.total_pages @audits.total_pages

json.audits do
 json.array! @audits, partial: "audits/audit", as: :audit
end