class AddTypeToFolderDocument < ActiveRecord::Migration[5.1]
  def change
    add_column :folder_documents, :type, :string
  end
end
