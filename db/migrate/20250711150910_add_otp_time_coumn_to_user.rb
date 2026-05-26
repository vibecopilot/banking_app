class AddOtpTimeCoumnToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :otp_sent_at, :datetime
  end
end
