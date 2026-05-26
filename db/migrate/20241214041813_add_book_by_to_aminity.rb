class AddBookByToAminity < ActiveRecord::Migration[5.1]
  def change
    add_column :aminities, :book_by, :integer
  end
end
