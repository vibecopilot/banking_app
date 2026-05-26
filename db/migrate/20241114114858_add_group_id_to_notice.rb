class AddGroupIdToNotice < ActiveRecord::Migration[5.1]
  def change
    add_column :notices, :shared, :string
    add_column :notices, :group_id, :integer
    add_column :notices, :important, :boolean
  end
end
