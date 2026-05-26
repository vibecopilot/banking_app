class AddPrNoToLoiDetail < ActiveRecord::Migration[5.1]
  def change
    add_column :loi_details, :pr_no, :string
  end
end
