class AddBillingColumnToCompany < ActiveRecord::Migration[5.2]
  def change
    add_column :companies, :entity, :string
    add_column :companies, :site, :string
    add_column :companies, :country, :string
    add_column :companies, :region, :string
    add_column :companies, :state, :string
    add_column :companies, :city, :string
    add_column :companies, :zone, :string
    add_column :companies, :white_label, :string
    add_column :companies, :sub_domain, :string
    add_column :companies, :billing_type, :string
    add_column :companies, :billing_for, :string
    add_column :companies, :billing_term, :string
    add_column :companies, :rate_per_bill, :float
    add_column :companies, :billing_cycle, :string
    add_column :companies, :start_time, :date
    add_column :companies, :end_time, :date
  end
end
