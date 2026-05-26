class CreateOtherPAmenities < ActiveRecord::Migration[5.1]
  def change
    create_table :other_p_amenities do |t|
      t.integer :other_project_id
      t.string :name

      t.timestamps
    end

    add_index :other_p_amenities, :other_project_id
  end
end
