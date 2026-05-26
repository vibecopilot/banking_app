class CreateSnagChecklists < ActiveRecord::Migration[5.1]
  def change
    create_table :snag_checklists do |t|
      t.string :name
      t.integer :snag_audit_category_id
      t.integer :snag_audit_sub_category_id
      t.integer :active
      t.integer :site_id
      t.integer :company_id
      t.string :check_type
      t.integer :user_id
      t.integer :resource_id
      t.string :resource_type

      t.timestamps
    end
  end
end
