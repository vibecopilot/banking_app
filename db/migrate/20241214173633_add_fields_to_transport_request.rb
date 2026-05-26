class AddFieldsToTransportRequest < ActiveRecord::Migration[5.1]
  def change
    add_column :transport_requests, :start_date, :date
    add_column :transport_requests, :end_date, :date
    add_column :transport_requests, :drop_off_location, :string
  end
end
