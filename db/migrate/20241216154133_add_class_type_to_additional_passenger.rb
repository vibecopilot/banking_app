class AddClassTypeToAdditionalPassenger < ActiveRecord::Migration[5.1]
  def change
    add_column :additional_passengers, :class_type, :string
  end
end
