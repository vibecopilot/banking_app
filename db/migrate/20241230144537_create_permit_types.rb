class CreatePermitTypes < ActiveRecord::Migration[5.1]
  def change
    create_table :permit_types do |t|
      t.string :name
      t.integer :site_id

      t.timestamps
    end
  end
end
