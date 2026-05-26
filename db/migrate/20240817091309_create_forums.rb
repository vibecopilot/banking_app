class CreateForums < ActiveRecord::Migration[5.1]
  def change
    create_table :forums do |t|
      t.string :thread_title
      t.string :thread_category
      t.string :thread_tags
      t.string :thread_creators
      t.datetime :date
      t.text :thread_description

      t.timestamps
    end
  end
end
