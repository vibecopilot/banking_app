class ChangeIsApprovedTypeInLoiItems < ActiveRecord::Migration[5.1]
  def change
    change_column :loi_details, :is_approved, :string
  end
end
