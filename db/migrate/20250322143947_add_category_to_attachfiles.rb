class AddCategoryToAttachfiles < ActiveRecord::Migration[5.1]
  def change
    add_column :attachfiles, :category_type, :string
  end
end
