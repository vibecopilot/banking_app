class CreateNotices < ActiveRecord::Migration[5.1]
  def change
    create_table :notices do |t|
      t.integer :site_id
      t.string :notice_title
      t.text :notice_discription
      t.datetime :expiry_date

      t.timestamps
    end
  end
end
