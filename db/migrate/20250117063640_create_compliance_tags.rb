class CreateComplianceTags < ActiveRecord::Migration[5.1]
  def change
    create_table :compliance_tags do |t|
      t.string :name
      t.string :risk
      t.string :nature
      t.integer :parent_id
      t.integer :resource_id
      t.string :resource_type
      t.integer :company_id
      t.string :tag_type
      t.boolean :critical

      t.timestamps
    end
  end
end
