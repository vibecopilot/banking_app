class CreateExtraVisitors < ActiveRecord::Migration[5.1]
  def change
    create_table :extra_visitors do |t|
      t.string :name
      t.string :contact_no
      t.integer :visitor_id

      t.timestamps
    end
    add_index :extra_visitors, :visitor_id
  end
end
