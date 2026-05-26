class CreateNoticeUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :notice_users do |t|
      t.integer :notice_id
      t.integer :user_id

      t.timestamps
    end
  end
end
