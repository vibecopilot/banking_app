class CreateFeedbacks < ActiveRecord::Migration[5.1]
  def change
    create_table :feedbacks do |t|
      t.string :resource_type
      t.integer :resource_id
      t.text :comment
      t.integer :rating
      t.integer :user_id

      t.timestamps
    end
  end
end
