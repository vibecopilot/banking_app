class AddactiveColumnToFolderDocument < ActiveRecord::Migration[5.1]
  def change
    add_column  :folder_documents, :active, :boolean, default: true
  end
end
