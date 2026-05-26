class CreateAbouts < ActiveRecord::Migration[5.1]
  def change
    create_table :abouts do |t|
      t.text :description
      t.integer :site_id

      t.timestamps
    end
  end
end
