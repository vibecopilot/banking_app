class AddSiteColumnToAudit < ActiveRecord::Migration[5.1]
  def change
    add_column :audits, :site_id, :integer
  end
end
