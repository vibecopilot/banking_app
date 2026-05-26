class CreateRoleAccesses < ActiveRecord::Migration[5.2]
  def change
    create_table :role_accesses do |t|
      t.string :title
      t.references :site, foreign_key: true

      t.timestamps
    end
  end
end
