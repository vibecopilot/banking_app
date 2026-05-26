class AddHelpdeskCategoryToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :helpdesk_category_id, :integer
    add_column :users, :helpdesk_sub_category_id, :integer
    add_index :users, :helpdesk_category_id
    add_index :users, :helpdesk_sub_category_id
  end
end
