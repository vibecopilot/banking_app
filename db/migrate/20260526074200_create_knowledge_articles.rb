class CreateKnowledgeArticles < ActiveRecord::Migration[5.2]
  def change
    create_table :knowledge_articles do |t|
      t.string :title
      t.integer :category_id
      t.text :body
      t.text :tags
      t.string :status, default: "draft"
      t.integer :views, default: 0
      t.integer :helpful, default: 0
      t.integer :not_helpful, default: 0
      t.integer :site_id
      t.integer :created_by
      t.timestamps
    end
    add_index :knowledge_articles, :category_id
    add_index :knowledge_articles, :site_id
    add_index :knowledge_articles, :status
  end
end
