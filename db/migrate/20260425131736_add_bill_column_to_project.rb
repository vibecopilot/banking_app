class AddBillColumnToProject < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :company_name, :string
    add_column :projects, :entity, :string
    add_column :projects, :site, :string
    add_column :projects, :country, :string
    add_column :projects, :region, :string
    add_column :projects, :zone, :string
    add_column :projects, :white_label, :string
    add_column :projects, :sub_domain, :string
    add_column :projects, :billing_type, :string
    add_column :projects, :rate_per_bill, :float
    add_column :projects, :billing_for, :string
    add_column :projects, :billing_term, :string
    add_column :projects, :billing_cycle, :string
    add_column :projects, :start_date, :date
    add_column :projects, :end_date, :date
  end
end
