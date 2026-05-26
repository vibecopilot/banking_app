class AddCommentColumnToLoiDetail < ActiveRecord::Migration[5.1]
  def change
    add_column :loi_details, :loi_comments, :string
  end
end
