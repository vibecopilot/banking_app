class AddCheckoutToQrVerifications < ActiveRecord::Migration[5.1]
  def change
    add_column :qr_verifications, :checked_out, :boolean, default: false, null: false
    add_column :qr_verifications, :checked_out_at, :datetime
    add_column :qr_verifications, :checked_out_by_id, :integer
    
    add_index :qr_verifications, :checked_out
    add_index :qr_verifications, :checked_out_by_id
  end
end
