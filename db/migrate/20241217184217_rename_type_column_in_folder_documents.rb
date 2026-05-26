class RenameTypeColumnInFolderDocuments < ActiveRecord::Migration[5.1]
    def change
    rename_column :folder_documents, :type, :document_type
  end
end
