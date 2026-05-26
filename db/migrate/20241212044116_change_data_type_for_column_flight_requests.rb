class ChangeDataTypeForColumnFlightRequests < ActiveRecord::Migration[5.1]
def change
    # add_column :flight_requests, :mobile_no, :string
    add_column :flight_requests, :email, :string
    if column_exists?(:flight_requests, :mobile_no)
      change_column :flight_requests, :mobile_no, :string
    else
      Rails.logger.warn("Column 'mobile_no' does not exist in 'flight_requests'. Skipping migration.")
    end
  end
end
