class AddSecureQrFieldsToVisitors < ActiveRecord::Migration[5.1]
  def change
    add_column :visitors, :qr_token_digest, :string unless column_exists?(:visitors, :qr_token_digest)
    add_column :visitors, :qr_generated_at, :datetime unless column_exists?(:visitors, :qr_generated_at)
    add_column :visitors, :qr_pending_expiry_minutes, :integer unless column_exists?(:visitors, :qr_pending_expiry_minutes)
    add_column :visitors, :qr_checked_in_at, :datetime unless column_exists?(:visitors, :qr_checked_in_at)
    add_column :visitors, :is_deleted, :boolean, default: false 

    add_index :visitors, :qr_token_digest unless index_exists?(:visitors, :qr_token_digest)
    add_index :visitors, :qr_generated_at unless index_exists?(:visitors, :qr_generated_at)
  end
end
