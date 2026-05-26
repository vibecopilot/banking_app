class AddFaceAddedToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :face_added, :boolean
  end
end
