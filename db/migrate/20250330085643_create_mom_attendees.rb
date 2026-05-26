class CreateMomAttendees < ActiveRecord::Migration[5.1]
  def change
    create_table :mom_attendees do |t|
      t.references :mom_detail, foreign_key: true
      t.string :name
      t.string :organization
      t.string :role
      t.string :email
      t.string :company_tag_name
      t.integer :attendees_id
      t.string :attendees_type

      t.timestamps
    end
  end
end
