class AddGracePeriodToChecklist < ActiveRecord::Migration[5.1]
  def change
    add_column :checklists, :grace_period, :integer
  end
end
