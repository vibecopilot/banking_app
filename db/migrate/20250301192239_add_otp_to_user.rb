class AddOtpToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :otp, :string
  end
end
