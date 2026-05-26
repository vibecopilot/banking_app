class CreateTicketLogs < ActiveRecord::Migration[5.1]
  def change
    create_table :ticket_logs do |t|
      t.integer :ticket_id
      t.integer :created_by_id
      t.string :status
      t.string :log_type
      t.text :remarks

      t.timestamps
    end
  end
end
