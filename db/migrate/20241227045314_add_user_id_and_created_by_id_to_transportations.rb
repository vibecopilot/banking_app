class AddUserIdAndCreatedByIdToTransportations < ActiveRecord::Migration[5.1]
  def change
    add_column :transportations, :user_id, :integer
    add_column :transportations, :created_by_id, :integer

    add_index :transportations, :user_id
    add_index :transportations, :created_by_id
  end
end
