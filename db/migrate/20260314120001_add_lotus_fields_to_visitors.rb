class AddLotusFieldsToVisitors < ActiveRecord::Migration[5.2]
  def change
    add_column :visitors, :lotus_token, :text
    add_column :visitors, :start_date, :date
    add_column :visitors, :end_date, :date
  end
end
