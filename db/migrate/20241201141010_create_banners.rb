class CreateBanners < ActiveRecord::Migration[5.1]
  def change
    create_table :banners do |t|
      t.string :title
      t.text :description
      t.integer :site_id

      t.timestamps
    end
  end
end
