class CreateUserMembers < ActiveRecord::Migration[5.1]
  def change
    create_table :user_members do |t|
      t.string :member_type
      t.string :member_name
      t.string :contact_no
      t.string :relation
      t.references :user, foreign_key: true
      t.timestamps
    end
  end
end
