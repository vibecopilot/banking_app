class AddGracePeriodToChecklists < ActiveRecord::Migration[5.1]
  def change
    add_column :checklists, :grace_period_unit, :string
    add_column :checklists, :grace_period_value, :integer
  end
end
