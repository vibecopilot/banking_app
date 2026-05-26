class AddStatusTypeColumnToStaff < ActiveRecord::Migration[5.1]
  def change
      add_column :staffs, :status_type, :string, default: 'Pending'
      add_column :staffs, :created_by_id, :integer
  end
end
