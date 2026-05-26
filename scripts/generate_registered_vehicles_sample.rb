require 'bundler/setup'
require 'axlsx'

# Generate sample Excel file for registered vehicles import
package = Axlsx::Package.new
workbook = package.workbook

# Define styles
header_style = workbook.styles.add_style(
  bg_color: "0066CC",
  fg_color: "FFFFFF",
  b: true,
  alignment: { horizontal: :center, vertical: :center, wrap_text: true },
  border: { style: :thin, color: "000000" }
)

data_style = workbook.styles.add_style(
  alignment: { horizontal: :left, vertical: :center },
  border: { style: :thin, color: "CCCCCC" }
)

date_style = workbook.styles.add_style(
  format_code: "YYYY-MM-DD",
  alignment: { horizontal: :left, vertical: :center },
  border: { style: :thin, color: "CCCCCC" }
)

workbook.add_worksheet(name: "Registered Vehicles") do |sheet|
  # Header row
  sheet.add_row [
    "VehicleNumber",
    "VehicleType",
    "VehicleCategory",
    "RegistrationNumber",
    "InsuranceNumber",
    "InsuranceValidTill",
    "ValidTill",
    "Category",
    "Status",
    "Approved",
    "UnitName",
    "UserEmail",
    "SlotNumber"
  ], style: header_style

  # Sample data rows
  sheet.add_row [
    "MH01AB1234",
    "Car",
    "Four Wheeler",
    "REG123456",
    "INS987654",
    "2025-12-31",
    "2025-12-31",
    "Resident",
    "Active",
    "Approved",
    "A-101",
    "user@example.com",
    "A-001"
  ], style: [data_style] * 10 + [date_style, date_style] + [data_style]

  sheet.add_row [
    "MH02CD5678",
    "Bike",
    "Two Wheeler",
    "REG789012",
    "INS456789",
    "2026-06-30",
    "2026-06-30",
    "Visitor",
    "Active",
    "Pending",
    "B-205",
    "visitor@example.com",
    "B-015"
  ], style: [data_style] * 10 + [date_style, date_style] + [data_style]

  # Set column widths
  sheet.column_widths 18, 15, 18, 20, 18, 18, 15, 15, 12, 12, 15, 25, 15
end

# Add Instructions sheet
workbook.add_worksheet(name: "Instructions") do |sheet|
  instruction_header = workbook.styles.add_style(
    b: true,
    sz: 14,
    fg_color: "0066CC"
  )
  
  instruction_text = workbook.styles.add_style(
    alignment: { wrap_text: true, vertical: :top }
  )

  sheet.add_row ["Registered Vehicles Import Instructions"], style: instruction_header
  sheet.add_row []
  
  sheet.add_row ["Field Descriptions:"], style: workbook.styles.add_style(b: true)
  sheet.add_row ["VehicleNumber", "Required. The vehicle registration number (e.g., MH01AB1234)"], style: instruction_text
  sheet.add_row ["VehicleType", "Optional. Type of vehicle (e.g., Car, Bike, SUV, Truck)"], style: instruction_text
  sheet.add_row ["VehicleCategory", "Optional. Category (e.g., Two Wheeler, Four Wheeler)"], style: instruction_text
  sheet.add_row ["RegistrationNumber", "Optional. Official registration number"], style: instruction_text
  sheet.add_row ["InsuranceNumber", "Optional. Vehicle insurance policy number"], style: instruction_text
  sheet.add_row ["InsuranceValidTill", "Optional. Insurance expiry date (Format: YYYY-MM-DD)"], style: instruction_text
  sheet.add_row ["ValidTill", "Optional. Vehicle registration validity date (Format: YYYY-MM-DD)"], style: instruction_text
  sheet.add_row ["Category", "Optional. Vehicle category (e.g., Resident, Visitor, Staff)"], style: instruction_text
  sheet.add_row ["Status", "Optional. Current status (e.g., Active, Inactive)"], style: instruction_text
  sheet.add_row ["Approved", "Optional. Approval status (Approved, Rejected, Pending). Default: Pending"], style: instruction_text
  sheet.add_row ["UnitName", "Optional. Name of the unit/apartment"], style: instruction_text
  sheet.add_row ["UserEmail", "Optional. Email of the vehicle owner"], style: instruction_text
  sheet.add_row ["SlotNumber", "Optional. Parking slot number"], style: instruction_text
  
  sheet.add_row []
  sheet.add_row ["Important Notes:"], style: workbook.styles.add_style(b: true, fg_color: "FF0000")
  sheet.add_row ["1. VehicleNumber is mandatory and must be unique within the site"], style: instruction_text
  sheet.add_row ["2. Date format must be YYYY-MM-DD (e.g., 2025-12-31)"], style: instruction_text
  sheet.add_row ["3. If UnitName is provided, it must exist in the system"], style: instruction_text
  sheet.add_row ["4. If UserEmail is provided, the user must exist in the system"], style: instruction_text
  sheet.add_row ["5. If SlotNumber is provided, the parking slot must exist in the system"], style: instruction_text
  sheet.add_row ["6. Duplicate vehicle numbers in the same site will be rejected"], style: instruction_text
  
  sheet.column_widths 25, 80
end

# Save the file
output_path = File.join(File.dirname(__FILE__), '..', 'public', 'sample_files', 'import_registered_vehicles.xlsx')
package.serialize(output_path)

puts "Sample file created successfully at: #{output_path}"
