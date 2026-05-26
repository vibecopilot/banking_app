class CreateBusinessCards < ActiveRecord::Migration[5.1]
  def change
    create_table :business_cards do |t|
      t.string :full_name
      t.string :profession
      t.string :contact_number
      t.string :email_id
      t.string :website_url
      t.text :address

      t.timestamps
    end
  end
end
