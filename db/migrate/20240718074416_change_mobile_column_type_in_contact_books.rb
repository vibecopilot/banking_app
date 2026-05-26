class ChangeMobileColumnTypeInContactBooks < ActiveRecord::Migration[5.1]
  def change
    change_column :contact_books, :mobile, :bigint
  end
end
