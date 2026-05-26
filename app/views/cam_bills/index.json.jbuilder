json.total_count @cam_bills.total_entries
json.current_page @cam_bills.current_page
json.total_pages @cam_bills.total_pages

json.cam_bills do
 json.array! @cam_bills, partial: "cam_bills/cam_bill", as: :cam_bill
end