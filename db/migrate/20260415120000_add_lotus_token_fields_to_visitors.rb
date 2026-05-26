class AddLotusTokenFieldsToVisitors < ActiveRecord::Migration[5.2]
  def change
    add_column :visitors, :lotus_token, :text unless column_exists?(:visitors, :lotus_token)
    add_column :visitors, :start_date, :date unless column_exists?(:visitors, :start_date)
    add_column :visitors, :end_date, :date unless column_exists?(:visitors, :end_date)
  end
end
