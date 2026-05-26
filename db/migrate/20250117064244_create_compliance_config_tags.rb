class CreateComplianceConfigTags < ActiveRecord::Migration[5.1]
  def change
    create_table :compliance_config_tags do |t|
      t.integer :compliance_tag_id
      t.integer :compliance_config_id

      t.timestamps
    end
  end
end
