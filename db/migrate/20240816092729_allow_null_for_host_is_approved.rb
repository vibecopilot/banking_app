class AllowNullForHostIsApproved < ActiveRecord::Migration[5.1]
  def up
    change_column :hosts, :is_approved, :boolean, null: true
  end

  def down
    change_column :hosts, :is_approved, :boolean, null: false
  end
end
