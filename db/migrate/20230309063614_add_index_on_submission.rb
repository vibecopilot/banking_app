class AddIndexOnSubmission < ActiveRecord::Migration[5.1]
  def change
    add_index :submissions, :created_at
  end
end
