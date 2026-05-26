class AddOrganizationIdToCompany < ActiveRecord::Migration[5.1]
  def change
    add_column :companies, :organization_id, :integer
  end
end
