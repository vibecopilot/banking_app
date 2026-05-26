class AddCreatedByToMultipleTables < ActiveRecord::Migration[5.1]
  def change
    add_column :folders, :created_by, :integer
    add_column :folder_documents, :created_by, :integer
  end
end
