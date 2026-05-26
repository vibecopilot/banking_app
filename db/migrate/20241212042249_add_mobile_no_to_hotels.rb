class AddMobileNoToHotels < ActiveRecord::Migration[5.1]
  def change
    add_column :hotels, :mobile_no, :string
    add_column :hotels, :email, :string
  end
end
