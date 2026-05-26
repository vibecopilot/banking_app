class CreateCards < ActiveRecord::Migration[5.2]
  def change
    create_table :cards do |t|
      t.string :company_code
      t.string :tag_type
      t.string :status
      t.json :card_data
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
