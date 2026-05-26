class AddColumnToContactBooks < ActiveRecord::Migration[5.1]
  def change
    add_column :contact_books, :status, :boolean, default: false
  end
end
