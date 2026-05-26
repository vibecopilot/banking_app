class AddDocColumnToVisitor < ActiveRecord::Migration[5.1]
  def change
    add_column :visitors, :driving_license, :boolean
    add_column :visitors, :consignment_form, :boolean
  end
end
