class AddCompanyIdToChecklist < ActiveRecord::Migration[5.1]
  def change
    add_column :checklists, :company_id, :integer
  end
end
