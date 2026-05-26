require 'roo'

class Inventory < ApplicationRecord

  def self.import_from_excel(file)
    spreadsheet = Roo::Spreadsheet.open(file.path)
    header = spreadsheet.row(1) # Assuming the first row is the header

    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      
      # Map the spreadsheet columns to the Inventory attributes
      inventory_params = {
        name: row['name'],
        inventory_type: row['inventory_type'],
        site_id: row['site_id'],
        criticality: row['criticality'],
        asset_group_id: row['asset_group_id'],
        asset_sub_group_id: row['asset_sub_group_id'],
        asset_id: row['asset_id'],
        code: row['code'],
        serial_number: row['serial_number'],
        quantity: row['quantity'],
        min_stock_level: row['min_stock_level'],
        min_order_level: row['min_order_level'],
        cgst_rate: row['cgst_rate'],
        sgst_rate: row['sgst_rate'],
        igst_rate: row['igst_rate'],
        active: row['active'],
        hsn_id: row['hsn_id'],
        expiry_date: row['expiry_date'],
        unit: row['unit'],
        cost: row['cost']
      }
      
      # Create the Inventory item
      Inventory.create!(inventory_params)
    end
  rescue StandardError => e
    raise "Failed to import data: #{e.message}"
  end

  belongs_to :site_asset, class_name: "SiteAsset", foreign_key: :asset_id
  belongs_to :asset_group, class_name: "AssetGroup", foreign_key: :asset_group_id, optional: true
  belongs_to :sub_group, class_name: "SubGroup", foreign_key: :asset_sub_group_id, optional: true

end