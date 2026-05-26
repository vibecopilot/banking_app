class CreateEvents < ActiveRecord::Migration[5.1]
  def change
    create_table :events do |t|
      t.integer :site_id
      t.string :event_name
      t.string :venue
      t.string :discription
      t.datetime :start_date_time
      t.datetime :end_date_time

      t.timestamps
    end
  end
end
