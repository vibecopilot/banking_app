class AddTypeToPermitActivitySetup < ActiveRecord::Migration[5.1]
  def change
    add_column :permit_activity_setups, :type, :string
  end
end
