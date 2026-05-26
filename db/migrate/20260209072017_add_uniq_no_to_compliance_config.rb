class AddUniqNoToComplianceConfig < ActiveRecord::Migration[5.1]
  def change
    add_column :compliance_configs, :cert_number, :string
  end
end
