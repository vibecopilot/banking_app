class CreateVisitorCards < ActiveRecord::Migration[5.2]
  def change
    create_table :visitor_cards do |t|
      t.string :company_code
      t.string :tag_type
      t.string :status
      t.json :card_data
      t.string :card_id
      t.references :visitor, foreign_key: true

      t.timestamps
    end
    
    add_index :visitor_cards, [:card_id, :visitor_id], unique: true
  end
end
