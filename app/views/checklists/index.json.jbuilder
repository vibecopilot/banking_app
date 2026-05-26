json.total_entries @checklists.respond_to?(:total_count) ? @checklists.total_count : @checklists.size
json.total_pages   @checklists.respond_to?(:total_pages) ? @checklists.total_pages : 1
json.current_page  @checklists.respond_to?(:current_page) ? @checklists.current_page : 1

json.checklists do 
json.array! @checklists, partial: "checklists/checklist", as: :checklist
end