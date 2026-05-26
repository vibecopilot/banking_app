class AddImageAndNotesToPayments < ActiveRecord::Migration[5.1]
  def change
    add_attachment :payments, :image
    add_column :payments, :notes, :text
  end
end
