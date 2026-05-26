class AddStatusColumnToNotice < ActiveRecord::Migration[5.1]
  def change
    # add_column :notices, :status, :string
    add_column :notices, :status, :string, default: 'upcoming'
  end
end
