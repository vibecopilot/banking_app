class CreateUserVendors < ActiveRecord::Migration[5.1]
  def change
    create_table :user_vendors do |t|
      t.string :service_type
      t.string :name
      t.string :contact_no
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
