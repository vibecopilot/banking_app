class AddSiteColumnToSite < ActiveRecord::Migration[5.2]
  def change
    add_column :sites, :site_code, :string
    add_column :sites, :project_id, :integer
    add_column :sites, :country, :string
    add_column :sites, :activation_date, :date
    add_column :sites, :site_owner, :string
    add_column :sites, :phone_no, :string
    add_column :sites, :email_address, :string
  end
end
