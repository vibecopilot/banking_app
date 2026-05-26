# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

CamSetting.first_or_create!(rate_per_sqft: 3.5, gst_rate_percent: 18, advance_months_required: 24)

# Seed Chart of Accounts for the first site
site = Site.first || Site.create!(name: 'Default Site')

# Define the chart of accounts structure
# Helper method to create groups and sub-groups with ledgers
def create_account_structure(site, data)
  data.each do |group_data|
    group_name = group_data[:group]
    group_type = group_data[:group_type]
    
    # Create primary group
    primary_group = AccountGroup.find_or_create_by!(
      name: group_name,
      code: group_name.upcase.gsub(/\s+/, '_'),
      group_type: group_type,
      site_id: site.id,
      is_system: true,
      active: true
    )
    
    # Create sub-groups and ledgers
    group_data[:sub_groups].each do |sub_group_data|
      sub_group_name = sub_group_data[:name]
      
      # Create sub-group
      sub_group = AccountGroup.find_or_create_by!(
        name: sub_group_name,
        code: "#{primary_group.code}_#{sub_group_name.upcase.gsub(/\s+/, '_')}",
        group_type: group_type,
        parent_id: primary_group.id,
        site_id: site.id,
        is_system: true,
        active: true
      )
      
      # Create ledgers
      sub_group_data[:ledgers].each_with_index do |ledger_name, idx|
        Ledger.find_or_create_by!(
          name: ledger_name,
          code: "#{sub_group.code}_#{idx + 1}",
          account_group_id: sub_group.id,
          site_id: site.id,
          ledger_type: 'general',
          is_system: true,
          active: true
        )
      end
    end
  end
end

# LIABILITIES
liabilities_data = {
  group: 'Liabilities',
  group_type: 'liability',
  sub_groups: [
    {
      name: 'Capital & Reserves',
      ledgers: [
        'Society Members\' Corpus / Apex Fund',
        'Corpus Fund – Members',
        'Corpus Fund – Interest Earned',
        'Sinking Fund – Principal',
        'Sinking Fund – Interest Earned',
        'Repair & Maintenance Fund – Contributions',
        'Repair & Maintenance Fund – Utilisation',
        'General Reserve'
      ]
    },
    {
      name: 'Member Related Liabilities',
      ledgers: [
        'Maintenance Charges Payable – Current Year',
        'Parking Charges Payable – Covered',
        'Parking Charges Payable – Open',
        'Club House Charges Payable',
        'Swimming Pool Charges Payable',
        'Late Payment Charges Accrued',
        'Interest on Overdue Maintenance Accrued',
        'Advance Maintenance – Tower A',
        'Advance Maintenance – Tower B'
      ]
    },
    {
      name: 'Statutory & Tax Liabilities',
      ledgers: [
        'GST Output – CGST',
        'GST Output – SGST',
        'GST Output – IGST',
        'TDS Payable on Contractors',
        'Professional Tax Payable (Employees)'
      ]
    },
    {
      name: 'Vendor & Expense Liabilities',
      ledgers: [
        'Sundry Creditors – Housekeeping Vendor',
        'Sundry Creditors – Security Agency',
        'Sundry Creditors – Lift AMC Vendor',
        'Sundry Creditors – Electricity Utility',
        'Vendor Security Deposit – Housekeeping',
        'Accrued Electricity Charges',
        'Accrued Audit Fees'
      ]
    }
  ]
}

# ASSETS
assets_data = {
  group: 'Assets',
  group_type: 'asset',
  sub_groups: [
    {
      name: 'Bank & Cash',
      ledgers: [
        'Cash-in-Hand – Office',
        'Bank – Maintenance Account',
        'Bank – Sinking Fund Account',
        'Bank – Corpus Fund Account',
        'Fixed Deposit – Sinking Fund',
        'Fixed Deposit – Corpus Fund'
      ]
    },
    {
      name: 'Member Assets',
      ledgers: [
        'Maintenance Receivable – Tower A',
        'Maintenance Receivable – Tower B',
        'Parking Charges Receivable',
        'Club House Charges Receivable',
        'Member Caution Deposit – Club House',
        'Member Deposit – Access Card'
      ]
    },
    {
      name: 'Other Current Assets',
      ledgers: [
        'Prepaid Insurance',
        'Prepaid AMC – Lift',
        'Advance to Housekeeping Vendor',
        'Advance to Security Agency',
        'TDS Receivable on FD Interest'
      ]
    },
    {
      name: 'Fixed Assets – Building & Infrastructure',
      ledgers: [
        'Building Structure – Residential Blocks',
        'Compound Wall & Gate'
      ]
    },
    {
      name: 'Fixed Assets – Plant & Equipment',
      ledgers: [
        'Lift & Elevators',
        'DG Set',
        'Water Pump & STP Equipment',
        'Solar Power System',
        'CCTV & Security System'
      ]
    },
    {
      name: 'Fixed Assets – Furniture & Office',
      ledgers: [
        'Club House Furniture',
        'Office Furniture & Equipment'
      ]
    }
  ]
}

# INCOME
income_data = {
  group: 'Income',
  group_type: 'income',
  sub_groups: [
    {
      name: 'Maintenance & Common Area Income',
      ledgers: [
        'Maintenance Charges – Residential Flats',
        'Maintenance Charges – Shops / Commercial',
        'Common Electricity Recovery – Corridors & Lifts',
        'Water Charges Recovery – Common',
        'Lift Maintenance Recovery'
      ]
    },
    {
      name: 'Reserve Contributions from Members',
      ledgers: [
        'Sinking Fund Contribution – Members',
        'Corpus / Apex Fund Contribution – Members',
        'Repair & Maintenance Fund Contribution – Members'
      ]
    },
    {
      name: 'Parking Income',
      ledgers: [
        'Parking Income – Open Parking',
        'Parking Income – Stilt / Basement'
      ]
    },
    {
      name: 'Amenity Income',
      ledgers: [
        'Club House Membership Fees',
        'Club House Booking Charges – Party Hall',
        'Swimming Pool Usage Charges',
        'Gym / Indoor Games Charges'
      ]
    },
    {
      name: 'Penalty & Interest Income',
      ledgers: [
        'Late Payment Charges – Maintenance',
        'Interest on Overdue Maintenance'
      ]
    },
    {
      name: 'Rental & Miscellaneous Income',
      ledgers: [
        'Rental Income – Mobile Tower',
        'Rental Income – Hoardings / Signage',
        'Advertisement Income – Common Areas',
        'Miscellaneous Income – Others'
      ]
    }
  ]
}

# EXPENSES
expenses_data = {
  group: 'Expenses',
  group_type: 'expense',
  sub_groups: [
    {
      name: 'Housekeeping Expenses',
      ledgers: [
        'Housekeeping Charges – Common Area',
        'Housekeeping Consumables'
      ]
    },
    {
      name: 'Security Expenses',
      ledgers: [
        'Security Charges – Guards',
        'Security System Maintenance'
      ]
    },
    {
      name: 'Lift & DG Expenses',
      ledgers: [
        'Lift AMC & Repairs',
        'DG Fuel & Maintenance'
      ]
    },
    {
      name: 'Utilities & Services Expenses',
      ledgers: [
        'Common Electricity Expense',
        'Water Charges / Tanker Water',
        'STP / WTP Running Expense'
      ]
    },
    {
      name: 'Amenities & Common Area Expenses',
      ledgers: [
        'Garden & Landscape Maintenance',
        'Club House Operation Expenses',
        'Swimming Pool Maintenance'
      ]
    },
    {
      name: 'Administrative Expenses',
      ledgers: [
        'Office Salaries & Honorarium',
        'Office Rent',
        'Printing & Stationery',
        'Telephone & Internet – Office',
        'Bank Charges & Commission',
        'Software Subscription – Accounting / Society App'
      ]
    },
    {
      name: 'Statutory & Compliance Expenses',
      ledgers: [
        'Audit Fees',
        'Legal & Consultancy Charges',
        'Society Registration & Filing Fees',
        'Insurance Premium – Building & Assets'
      ]
    },
    {
      name: 'Event & Community Expenses',
      ledgers: [
        'Festival & Cultural Expenses',
        'AGM / SGM Meeting Expenses',
        'Community Welfare / CSR Activities'
      ]
    },
    {
      name: 'Reserve Utilisation Expenses',
      ledgers: [
        'Major Structural Repair Expenses',
        'External Painting Expenses',
        'Lift Modernisation (From Sinking Fund)'
      ]
    }
  ]
}

# OTHER INCOME & EXPENSES
other_income_data = {
  group: 'Other Income',
  group_type: 'income',
  sub_groups: [
    {
      name: 'Interest & Miscellaneous Income',
      ledgers: [
        'Interest on FD – Sinking Fund',
        'Interest on FD – Corpus Fund',
        'Interest on Savings Bank Account',
        'Write-back of Old Credit Balances'
      ]
    }
  ]
}

other_expenses_data = {
  group: 'Other Expenses',
  group_type: 'expense',
  sub_groups: [
    {
      name: 'Adjustments & Miscellaneous Expenses',
      ledgers: [
        'Prior Period Expense Adjustments',
        'Rounding Off Difference'
      ]
    }
  ]
}

# Create all account structures
puts "Seeding Chart of Accounts..."
create_account_structure(site, [liabilities_data])
create_account_structure(site, [assets_data])
create_account_structure(site, [income_data])
create_account_structure(site, [expenses_data])
create_account_structure(site, [other_income_data])
create_account_structure(site, [other_expenses_data])

puts "Chart of Accounts seeded successfully!"
puts "Total Groups: #{AccountGroup.count}"
puts "Total Ledgers: #{Ledger.count}"
