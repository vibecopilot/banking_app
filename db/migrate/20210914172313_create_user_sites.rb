class CreateUserSites < ActiveRecord::Migration[5.1]
  def change
    create_table :user_sites do |t|
      t.integer :user_id
      t.integer :site_id
      t.boolean :is_current

      t.timestamps
    end
  end
end
