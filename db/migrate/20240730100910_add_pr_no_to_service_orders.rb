class AddPrNoToServiceOrders < ActiveRecord::Migration[5.1]
  def change
    add_column :service_orders, :pr_no, :string
  end
end
