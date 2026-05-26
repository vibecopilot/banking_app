class CreateAttachfiles < ActiveRecord::Migration[5.1]
  def change
    create_table :attachfiles do |t|
      t.string :relation
      t.integer :relation_id
      t.attachment :image
      t.boolean :active

      t.timestamps
    end
  end
end
