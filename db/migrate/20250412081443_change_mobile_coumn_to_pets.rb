class ChangeMobileCoumnToPets < ActiveRecord::Migration[5.1]
  def change
    change_column :pets , :owner_mobile_no, :string
  end
end
