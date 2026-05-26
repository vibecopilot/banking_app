namespace :inventories do
  desc "Generate sample import file for inventories"
  task generate_sample: :environment do
    require 'caxlsx'

    package = Axlsx::Package.new
    workbook = package.workbook

    # Add a worksheet
    workbook.add_worksheet(name: "Inventories Import") do |sheet|
      # Header row with all required fields
      sheet.add_row [
        'name',
        'inventory_type',
        'site_id',
        'criticality',
        'asset_group_id',
        'asset_sub_group_id',
        'asset_id',
        'code',
        'serial_number',
        'quantity',
        'min_stock_level',
        'min_order_level',
        'cgst_rate',
        'sgst_rate',
        'igst_rate',
        'active',
        'hsn_id',
        'expiry_date',
        'unit',
        'cost'
      ]

      # Sample data row
      sheet.add_row [
        'Sample Inventory Item',  # name
        'Spare Part',              # inventory_type
        '1',                       # site_id
        'High',                    # criticality
        '1',                       # asset_group_id
        '1',                       # asset_sub_group_id
        '1',                       # asset_id
        'INV001',                  # code
        'SN123456',                # serial_number
        '100',                     # quantity
        '10',                      # min_stock_level
        '20',                      # min_order_level
        '9',                       # cgst_rate
        '9',                       # sgst_rate
        '18',                      # igst_rate
        'true',                    # active
        '1',                       # hsn_id
        '2026-12-31',              # expiry_date
        'pcs',                     # unit
        '500.00'                   # cost
      ]

      # Add a second sample row
      sheet.add_row [
        'Motor Oil Filter',
        'Consumable',
        '1',
        'Medium',
        '2',
        '2',
        '2',
        'INV002',
        'SN789012',
        '50',
        '5',
        '10',
        '9',
        '9',
        '18',
        'true',
        '2',
        '2027-06-30',
        'pcs',
        '250.00'
      ]
    end

    # Instructions worksheet
    workbook.add_worksheet(name: "Instructions") do |sheet|
      sheet.add_row ['Inventory Import Instructions']
      sheet.add_row []
      sheet.add_row ['Column', 'Description', 'Required', 'Example']
      sheet.add_row ['name', 'Name of the inventory item', 'Yes', 'Air Filter']
      sheet.add_row ['inventory_type', 'Type of inventory', 'No', 'Spare Part / Consumable']
      sheet.add_row ['site_id', 'ID of the site', 'Yes', '1']
      sheet.add_row ['criticality', 'Criticality level', 'No', 'High / Medium / Low']
      sheet.add_row ['asset_group_id', 'Asset group ID', 'No', '1']
      sheet.add_row ['asset_sub_group_id', 'Asset sub-group ID', 'No', '1']
      sheet.add_row ['asset_id', 'Associated asset ID', 'No', '1']
      sheet.add_row ['code', 'Inventory code', 'No', 'INV001']
      sheet.add_row ['serial_number', 'Serial number', 'No', 'SN123456']
      sheet.add_row ['quantity', 'Current quantity', 'No', '100']
      sheet.add_row ['min_stock_level', 'Minimum stock level', 'No', '10']
      sheet.add_row ['min_order_level', 'Minimum reorder level', 'No', '20']
      sheet.add_row ['cgst_rate', 'Central GST rate (%)', 'No', '9']
      sheet.add_row ['sgst_rate', 'State GST rate (%)', 'No', '9']
      sheet.add_row ['igst_rate', 'Integrated GST rate (%)', 'No', '18']
      sheet.add_row ['active', 'Active status', 'No', 'true / false']
      sheet.add_row ['hsn_id', 'HSN code ID', 'No', '1']
      sheet.add_row ['expiry_date', 'Expiry date', 'No', '2026-12-31']
      sheet.add_row ['unit', 'Unit of measurement', 'No', 'pcs / kg / ltr']
      sheet.add_row ['cost', 'Unit cost', 'No', '500.00']
      sheet.add_row []
      sheet.add_row ['Notes:']
      sheet.add_row ['- Dates should be in YYYY-MM-DD format']
      sheet.add_row ['- Boolean values should be "true" or "false"']
      sheet.add_row ['- IDs must match existing records in the database']
      sheet.add_row ['- Keep the header row intact (row 1 in Inventories Import sheet)']
    end

    # Save the file
    file_path = Rails.root.join('public', 'sample_files', 'import_inventories.xlsx')
    package.serialize(file_path)

    puts "Sample file generated at: #{file_path}"
  end
end
