class AddColumnsToLoiDetails < ActiveRecord::Migration[5.1]
  def change
    add_column :loi_details, :payment_tenure, :integer
    add_column :loi_details, :advance_amount, :float
  end
end
