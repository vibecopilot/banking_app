require 'csv'

class CamBill < ApplicationRecord
    self.table_name = 'cam_bills'
    
    belongs_to :site, foreign_key: 'site_id', class_name: 'Site'
    belongs_to :address, foreign_key: 'invoice_address_id', class_name: 'AddressSetup', optional: true
    belongs_to :user, foreign_key: 'user_id', class_name: 'User',optional: true

    belongs_to :building, foreign_key: 'building_id', class_name: 'Building',optional: true
    belongs_to :unit, foreign_key: 'unit_id', class_name: 'Unit',optional: true

  has_many :cam_bill_charges, foreign_key: 'cam_bill_id', class_name: 'CamBillCharge'
  has_many :interest_calculations, dependent: :destroy
  has_many :income_entries, as: :source, dependent: :nullify
  accepts_nested_attributes_for :cam_bill_charges, allow_destroy: true
  after_create :notify_assigned_to, if: -> { self.user_id.present? }

  # Scopes
  scope :overdue, -> { where('due_date < ? AND payment_status != ?', Date.today, 'paid') }
  scope :pending, -> { where(payment_status: 'pending') }
  scope :paid, -> { where(payment_status: 'paid') }

  # Calculate and update interest for overdue bills
  def calculate_interest(interest_rate = 18.0, grace_period_days = 5)
    return 0 unless due_date.present? && total_amount.present?
    return 0 if payment_status == 'paid'
    
    # Calculate days overdue after grace period
    days_overdue = (Date.today - due_date).to_i - grace_period_days
    return 0 if days_overdue <= 0
    
    # Calculate outstanding amount (total - already paid)
    paid_amount = income_entries.where(status: 'received').sum(:amount)
    outstanding_amount = total_amount - paid_amount
    return 0 if outstanding_amount <= 0
    
    # Calculate interest (simple interest): Principal * Rate * Time / 100
    # Rate is annual, so divide by 365 for daily calculation
    interest = (outstanding_amount * interest_rate * days_overdue) / (365 * 100)
    
    # Update the interest field
    update_column(:due_amount_interst, interest.round(2))
    
    # Create interest calculation record
    InterestCalculation.create!(
      site_id: site_id,
      unit_id: unit_id,
      cam_bill_id: id,
      principal_amount: outstanding_amount,
      interest_rate: interest_rate,
      interest_amount: interest.round(2),
      calculation_date: Date.today,
      from_date: due_date + grace_period_days.days,
      to_date: Date.today,
      days_overdue: days_overdue,
      status: 'calculated'
    )
    
    interest.round(2)
  end
  
  # Class method to calculate interest for all overdue bills
  def self.calculate_all_overdue_interest(interest_rate = 18.0, grace_period_days = 5)
    overdue.find_each do |bill|
      begin
        bill.calculate_interest(interest_rate, grace_period_days)
      rescue => e
        Rails.logger.error("Error calculating interest for bill #{bill.id}: #{e.message}")
      end
    end
  end
  
  # Get total amount including interest
  def total_with_interest
    (total_amount || 0) + (due_amount_interst || 0)
  end
  
  # Get paid amount
  def paid_amount
    income_entries.where(status: 'received').sum(:amount)
  end
  
  # Get outstanding amount including interest
  def outstanding_amount
    total_with_interest - paid_amount
  end

  def notify_assigned_to
      if user_id.present? && user_id != 0
        sendata = { title: "Bill Created", message: "New Bill is Created",  ntype: "bill",  user_id: self.user_id,company_id: self.site.company_id, record_id: self.id }
        PushNotification.push_to_devices(UserDevice.where(user_id: user_id), sendata)
      end
  end
def self.import(file, site_id)
  spreadsheet = Roo::Spreadsheet.open(file.path)
  header = spreadsheet.row(1).map { |h| h.to_s.strip.downcase.gsub(/\s+/, '_') }
  
  created_records = []
  current_bill = nil
  current_bill_key = nil
  pending_charges = []
  first_row_for_bill = nil
  
  (2..spreadsheet.last_row).each do |i|
    row = Hash[[header, spreadsheet.row(i)].transpose]
    
    Rails.logger.info "Processing row #{i}: #{row.inspect}"
    
    # Check if this row has bill details (unit_name or unit_id present means new bill)
    has_bill_details = row['unit_name'].present? || row['unit_id'].present? || row['invoice_number'].present?
    
    # Generate a unique key for grouping rows into bills
    # Use unit + bill_date + invoice_number as the key
    bill_key = if has_bill_details
      [
        row['unit_name'].to_s.strip.presence || row['unit_id'].to_s,
        parse_date(row['bill_date']).to_s,
        row['invoice_number'].to_s.strip
      ].join('|')
    else
      nil
    end
    
    # If this is a new bill (different key or first bill), save the previous bill and start a new one
    if has_bill_details && bill_key != current_bill_key
      # Save previous bill if exists
      if current_bill.present?
        pending_charges.each { |charge_data| current_bill.cam_bill_charges.build(charge_data) }
        if current_bill.save
          created_records << { row: first_row_for_bill, id: current_bill.id, status: 'success' }
        else
          created_records << { row: first_row_for_bill, errors: current_bill.errors.full_messages, status: 'failed' }
        end
      end
      
      # Find unit by name or ID
      unit = nil
      if row['unit_name'].present?
        unit = Unit.find_by(name: row['unit_name'].to_s.strip, site_id: site_id)
      elsif row['unit_id'].present?
        unit = Unit.find_by(id: row['unit_id'])
      end
      
      # Find building
      building = nil
      if row['building_name'].present?
        building = Building.find_by(name: row['building_name'].to_s.strip, site_id: site_id)
      elsif row['building_id'].present?
        building = Building.find_by(id: row['building_id'])
      end
      
      # Find floor
      floor = nil
      if row['floor_name'].present? && building.present?
        floor = Floor.find_by(name: row['floor_name'].to_s.strip, building_id: building.id)
      elsif row['floor_id'].present?
        floor = Floor.find_by(id: row['floor_id'])
      end
      
      # Find user by unit ownership or directly
      user = nil
      if row['user_id'].present?
        user = User.find_by(id: row['user_id'])
      elsif unit.present?
        user_site = UserSite.find_by(unit_id: unit.id, ownership: "Owner")
        user = user_site&.user
      end
      
      # Find invoice address
      invoice_address = nil
      if row['invoice_address_id'].present?
        invoice_address = Address.find_by(id: row['invoice_address_id'])
      end
      
      # Parse dates
      bill_date = parse_date(row['bill_date'])
      due_date = parse_date(row['due_date'])
      supply_date = parse_date(row['supply_date'])
      bill_period_start_date = parse_date(row['bill_period_start_date'])
      bill_period_end_date = parse_date(row['bill_period_end_date'])
      
      current_bill = CamBill.new(
        site_id: site_id,
        unit_id: unit&.id || row['unit_id'],
        user_id: user&.id || row['user_id'],
        building_id: building&.id || row['building_id'],
        floor_id: floor&.id || row['floor_id'],
        bill_date: bill_date,
        due_date: due_date,
        supply_date: supply_date,
        bill_period_start_date: bill_period_start_date,
        bill_period_end_date: bill_period_end_date,
        total_amount: row['total_amount'].to_f,
        sub_amount: row['sub_amount'].to_f,
        due_amount: row['due_amount'].to_f,
        due_amount_interst: row['due_amount_interest'].to_f,
        status: row['status'].presence || 'pending',
        invoice_number: row['invoice_number'],
        invoice_type: row['invoice_type'],
        invoice_address_id: invoice_address&.id || row['invoice_address_id'],
        payment_status: row['payment_status'],
        note: row['note'],
        recall_reason: row['recall_reason'],
        created_by: row['created_by']
      )
      
      current_bill_key = bill_key
      pending_charges = []
      first_row_for_bill = i
    end
    
    # Extract charges from row and add to pending charges
    charges = extract_charges_from_row(row)
    Rails.logger.info "Extracted charges for row #{i}: #{charges.inspect}"
    pending_charges.concat(charges)
  end
  
  # Save the last bill
  if current_bill.present?
    pending_charges.each { |charge_data| current_bill.cam_bill_charges.build(charge_data) }
    if current_bill.save
      created_records << { row: first_row_for_bill, id: current_bill.id, status: 'success' }
    else
      created_records << { row: first_row_for_bill, errors: current_bill.errors.full_messages, status: 'failed' }
    end
  end
  
  created_records
end

def self.parse_date(value)
  return nil if value.blank?
  
  if value.is_a?(Date) || value.is_a?(DateTime)
    return value.to_date
  end
  
  # Try parsing string dates
  begin
    Date.parse(value.to_s)
  rescue ArgumentError
    nil
  end
end

def self.extract_charges_from_row(row)
  charges = []
  
  # Check if charge columns exist
  if row['charge_id'].present? || row['charge_amount'].present? || row['description'].present?
    charge = {
      charge_id: row['charge_id'],
      charge_amount: row['charge_amount'].to_f,
      sub_amount: row['charge_sub_amount'].to_f,
      cgst_amount: row['cgst_amount'].to_f,
      igst_amount: row['igst_amount'].to_f,
      sgst_amount: row['sgst_amount'].to_f,
      description: row['description'] || row['charge_description'],
      discount_percent: row['discount_percent'].to_f,
      cgst_rate: row['cgst_rate'].to_f,
      sgst_rate: row['sgst_rate'].to_f,
      igst_rate: row['igst_rate'].to_f,
      quantity: row['quantity'].to_f,
      unit: row['charge_unit'] || row['unit'],
      rate: row['rate'].to_f,
      hsn_id: row['hsn_id'],
      taxable_value: row['taxable_value'].to_f,
      total: row['charge_total'].to_f,
      total_value: row['total_value'].to_f,
      discount_amount: row['discount_amount'].to_f
    }.compact
    
    charges << charge if charge[:charge_id].present? || charge[:description].present? || charge[:charge_amount].to_f > 0
  end
  
  charges
end



end
