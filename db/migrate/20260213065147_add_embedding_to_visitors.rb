class AddEmbeddingToVisitors < ActiveRecord::Migration[5.1]
  def change
    add_column :visitors, :embedding, :text
  end
end
