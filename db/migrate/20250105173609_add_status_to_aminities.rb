class AddStatusToAminities < ActiveRecord::Migration[5.1]
  def change
    add_column :aminities, :status, :string
  end
end
