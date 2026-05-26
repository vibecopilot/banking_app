class AddEmailColumnToPoll < ActiveRecord::Migration[5.1]
  def change
    add_column :polls, :send_mail, :boolean
  end
end
