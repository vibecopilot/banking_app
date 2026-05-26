class CreatePollUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :poll_users do |t|
      t.integer :poll_id
      t.integer :user_id

      t.timestamps
    end
  end
end
