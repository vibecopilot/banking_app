class AddWebsiteLinkToVendor < ActiveRecord::Migration[5.1]
  def change
    add_column :vendors, :website_link, :string
    add_column :vendors, :aggrement_start_date, :date
    add_column :vendors, :aggremenet_end_date, :date
    add_column :vendors, :spoc_person, :string
  end
end
