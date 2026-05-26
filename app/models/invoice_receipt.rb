require 'roo'

class InvoiceReceipt < ApplicationRecord
    belongs_to :address, foreign_key: 'address_id', class_name: 'AddressSetup',optional: true
    belongs_to :building, foreign_key: 'building_id', class_name: 'Building',optional: true
    belongs_to :unit, foreign_key: 'unit_id', class_name: 'Unit',optional: true
    belongs_to :cam_bill, foreign_key: 'resource_id', class_name: 'CamBill',optional: true
      # belongs_to :cam_bill, -> { where(resource_type: "CamBill") }, class_name: "CamBill", foreign_key: :resource_id

    belongs_to :vendor, foreign_key: 'vendor_id', class_name: 'Vendor',optional: true
  def self.import(file)
    spreadsheet = Roo::Spreadsheet.open(file.path)
    header = spreadsheet.row(1)
    row_comp = []
    added_count = 0
    errors = []

    (2..spreadsheet.last_row).each do |i|
      row_hash = { row_number: i }
      row = Hash[[header, spreadsheet.row(i)].transpose]
      
      invoice_receipt_data = row.slice(
        'receipt_number', 'invoice_number', 'building_id', 'unit_id', 'address_id',
        'payment_mode', 'amount_received', 'transaction_or_cheque_number', 'bank_name',
        'branch_name', 'payment_date', 'receipt_date', 'notes', 'cam_bill_id'
      )

      invoice_receipt = InvoiceReceipt.find_or_initialize_by(
        receipt_number: invoice_receipt_data['receipt_number']
      )

      invoice_receipt.assign_attributes(invoice_receipt_data)

      if invoice_receipt.save
        added_count += 1
        row_hash[:message] = "success"
      else
        row_hash[:message] = invoice_receipt.errors.full_messages.join(", ")
        errors << { row_number: i, errors: row_hash[:message] }
        Rails.logger.error("Error on Row #{i}: #{invoice_receipt.errors.full_messages.join(', ')}")
      end

      row_comp << row_hash
    end

    {
      added_count: added_count,
      errors: errors,
      rows: row_comp
    }
  end
end
