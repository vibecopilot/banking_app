class CreateSiteModules < ActiveRecord::Migration[5.2]
  def change
    create_table :site_modules do |t|
      t.references :site, foreign_key: true
      t.references :role_modules, foreign_key: true

      t.timestamps
    end
  end
end
