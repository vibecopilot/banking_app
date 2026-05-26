class CreateTicketItems < ActiveRecord::Migration[5.1]
  def change
    create_table :ticket_items do |t|
      t.integer :ticket_id
      t.integer :item_id
      t.float :rate
      t.integer :item_count

      t.timestamps
    end
  end
end
