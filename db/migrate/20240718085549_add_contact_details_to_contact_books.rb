class AddContactDetailsToContactBooks < ActiveRecord::Migration[5.1]
  def change
    rename_column :contact_books, :name, :company_name 
    add_column :contact_books, :contact_person_name, :string
    add_column :contact_books, :landline_no, :string
    add_column :contact_books, :primary_email, :string
    add_column :contact_books, :secondary_email, :string
    add_column :contact_books, :website, :string
    add_column :contact_books, :address, :text
    add_column :contact_books, :key_offering, :string
    add_column :contact_books, :description, :text
    add_column :contact_books, :profile, :string
  end
end
