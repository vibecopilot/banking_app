class AddStatusToEscHistories < ActiveRecord::Migration[5.2]
  def change
    add_column :esc_histories, :status, :string, default: "open"
    add_column :esc_histories, :resolved_at, :datetime
  end
end
