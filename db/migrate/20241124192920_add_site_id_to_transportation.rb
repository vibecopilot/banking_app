class AddSiteIdToTransportation < ActiveRecord::Migration[5.1]
  def change
    add_column :transportations, :site_id, :integer
  end
end
