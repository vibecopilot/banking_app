class CreateEventUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :event_users do |t|
      t.integer :event_id
      t.integer :user_id
      t.string :rsvp

      t.timestamps
    end
  end
end
