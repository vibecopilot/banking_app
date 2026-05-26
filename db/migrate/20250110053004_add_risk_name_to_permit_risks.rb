class AddRiskNameToPermitRisks < ActiveRecord::Migration[5.1]
  def change
    add_column :permit_risks, :risk_name, :string
  end
end
