class ChangePhoneNumberToBigInt < ActiveRecord::Migration[5.1]
  def change
    change_column :addresses, :phone_number, :bigint 
  end
end
