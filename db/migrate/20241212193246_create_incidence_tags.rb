class CreateIncidenceTags < ActiveRecord::Migration[5.1]
  def change
    create_table :incidence_tags do |t|
      t.string :name
      t.boolean :active
      t.integer :parent_id
      t.string :tag_type
      t.integer :resource_id
      t.string :resource_type
      t.text :comment

      t.timestamps
    end
  end
end
