class CreateDeletedUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :deleted_users do |t|
      t.string :email
      t.string :mobile
      t.string :first_name
      t.string :last_name

      t.timestamps
    end
  end
end
