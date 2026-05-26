class CreateSharedForums < ActiveRecord::Migration[5.1]
 def change
    create_table :shared_forums do |t|
      t.references :forum, null: false, foreign_key: true
      t.references :sender, null: false, foreign_key: { to_table: :users }
      t.references :receiver, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
