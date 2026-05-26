class AddFieldsToGdnDetail < ActiveRecord::Migration[5.1]
  def change
    add_column :gdn_details, :purpose_id, :integer
    add_column :gdn_details, :handover_to_id, :integer
    add_column :gdn_details, :comments, :text
    add_column :gdn_details, :quantity, :decimal
  end
end
