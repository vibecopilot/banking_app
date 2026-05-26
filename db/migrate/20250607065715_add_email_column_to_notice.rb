class AddEmailColumnToNotice < ActiveRecord::Migration[5.1]
  def change
    add_column :notices, :send_email, :boolean
    add_column :notices, :created_by_id, :integer
  end
end
