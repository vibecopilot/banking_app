class CreatePollVotes < ActiveRecord::Migration[5.1]
  def change
    create_table :poll_votes do |t|
      t.integer :poll_user_id
      t.references :poll, foreign_key: true
      t.references :poll_option, foreign_key: true

      t.timestamps
    end
  end
end
