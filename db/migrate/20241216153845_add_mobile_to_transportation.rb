class AddMobileToTransportation < ActiveRecord::Migration[5.1]
  def change
    add_column :transportations, :mobile_no, :string
  end
end
