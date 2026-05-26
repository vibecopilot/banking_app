class CreateEventGuests < ActiveRecord::Migration[5.1]
  def change
    create_table :event_guests do |t|
      t.integer :event_id
      t.string :name
      t.string :rsvp
      t.string :company_name
      t.string :email
      t.string :mobile
      t.string :business
      t.string :rules
      t.string :charges
      t.string :industry

      t.timestamps
    end
  end
end
