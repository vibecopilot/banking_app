class AddEnableColumnToNotice < ActiveRecord::Migration[5.1]
  def change
    add_column :notices, :enabled, :boolean , default: true
  end
end
