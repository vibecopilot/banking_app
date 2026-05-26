class AddNewColumnToOrganization < ActiveRecord::Migration[5.2]
  def change
    add_column :organizations, :company_name, :string
    add_column :organizations, :entity, :string
    add_column :organizations, :site, :string
    add_column :organizations, :country, :string
    add_column :organizations, :region, :string
    add_column :organizations, :state, :string
    add_column :organizations, :city, :string
    add_column :organizations, :zonr, :string
    add_column :organizations, :white_label, :boolean
    add_column :organizations, :sub_domain, :string
    add_column :organizations, :billing_type, :string
    add_column :organizations, :billing_for, :string
    add_column :organizations, :billing_term, :string
    add_column :organizations, :rate_per_bill, :float
    add_column :organizations, :billing_cycle, :string
    add_column :organizations, :start_time, :date
    add_column :organizations, :end_time, :date
  end
end
