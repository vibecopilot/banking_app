json.total_count @contact_books.total_entries
json.current_page @contact_books.current_page
json.total_pages @contact_books.total_pages

json.contact_books do
json.array! @contact_books, partial: "contact_books/contact_book", as: :contact_book
end