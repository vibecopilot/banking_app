class AddOnBehalfOfIdToTransportation < ActiveRecord::Migration[5.1]
  def change
    add_column :transportations, :on_behalf_id, :integer
  end
end
