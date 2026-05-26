class CreateUserRefferals < ActiveRecord::Migration[5.1]
  def change
    create_table :user_refferals do |t|
      t.integer :from_user_id
      t.integer :to_user_id
      t.string :name
      t.string :mobile
      t.string :email
      t.string :business
      t.string :amount

      t.timestamps
    end
  end
end
