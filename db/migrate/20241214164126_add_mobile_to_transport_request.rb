class AddMobileToTransportRequest < ActiveRecord::Migration[5.1]
  def change
    add_column :transport_requests, :mobile_no, :string
  end
end
