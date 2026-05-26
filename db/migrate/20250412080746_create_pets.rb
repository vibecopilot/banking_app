class CreatePets < ActiveRecord::Migration[5.1]
  def change
    create_table :pets do |t|
      t.string :pet_name
      t.integer :owner_mobile_no
      t.string :pet_breed
      t.string :gender
      t.string :colour
      t.string :age
      t.date :dob
      t.boolean :is_pet_transfered
      t.boolean :brought
      t.boolean :stray_pet_adopted
      t.boolean :whether_brought_from_current_city
      t.boolean :pet_born_to_owner_dog

      t.timestamps
    end
  end
end
