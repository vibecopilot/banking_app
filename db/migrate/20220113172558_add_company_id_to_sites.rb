class AddCompanyIdToSites < ActiveRecord::Migration[5.1]
  def change
    add_column :sites, :company_id, :integer
  end
end
