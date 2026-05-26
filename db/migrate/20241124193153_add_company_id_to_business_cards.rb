class AddCompanyIdToBusinessCards < ActiveRecord::Migration[5.1]
  def change
    add_column :business_cards, :site_id, :integer
    add_column :business_cards, :company_id, :integer
  end
end
