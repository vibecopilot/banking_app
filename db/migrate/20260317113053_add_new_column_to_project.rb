class AddNewColumnToProject < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :city, :string
    add_column :projects, :tower, :string
    add_column :projects, :pincode, :integer
    add_column :projects, :state, :string
    add_column :projects, :flat_no, :string
    add_column :projects, :intercom, :string
    add_column :projects, :ownership, :string
    add_column :projects, :lives_here, :string
    add_column :projects, :is_primary, :string
    add_column :projects, :address_line_one, :string
    add_column :projects, :address_line_two, :string
  end
end
