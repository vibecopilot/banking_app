class AddNewColumnToContactBooks < ActiveRecord::Migration[5.1]
  def change
    add_column :contact_books, :generic_sub_info_id, :integer
  end
end
