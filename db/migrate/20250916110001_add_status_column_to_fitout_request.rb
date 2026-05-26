class AddStatusColumnToFitoutRequest < ActiveRecord::Migration[5.1]
  def change
    add_column :fitout_requests, :status, :string
  end
end
