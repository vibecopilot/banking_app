class AddColumnsToServiceOrders < ActiveRecord::Migration[5.1]
  def change
    add_column :service_orders, :kind_attention, :string
    add_column :service_orders, :subject, :string
    add_column :service_orders, :description, :text
    add_column :service_orders, :terms_and_conditions, :text
  end
end
  