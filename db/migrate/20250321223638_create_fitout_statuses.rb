class CreateFitoutStatuses < ActiveRecord::Migration[5.1]
  def change
    create_table :fitout_statuses do |t|
      t.integer :society_id
      t.string :name
      t.string :color_code
      t.string :fixed_state
      t.integer :active
      t.integer :position
      t.string :of_phase
      t.string :of_atype

      t.timestamps
    end
  end
end
