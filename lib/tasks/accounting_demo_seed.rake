namespace :demo do
  desc 'Seed a dummy site with 10 records each for core accounting modules'
  task seed_accounting: :environment do
    user = User.first
    raise 'No user found. Please create at least one user before running this task.' unless user

    company = Company.find_or_create_by!(name: 'Demo Accounting Company') do |c|
      c.created_by_user = user
      c.organization_id = user.organization_id if user.respond_to?(:organization_id)
    end

    site = Site.find_or_create_by!(name: 'Demo Accounting Site') do |s|
      s.company = company
      s.region = 'Demo'
      s.active = true
    end

    project = Project.find_or_create_by!(name: 'Demo Accounting Site') do |p|
      p.user_id = user.id
      p.active = true
    end

    building = Building.find_or_create_by!(site_id: site.id, name: 'Demo Tower')
    floor = Floor.find_or_create_by!(site_id: site.id, building_id: building.id, name: '01')

    units = 10.times.map do |idx|
      unit = Unit.find_or_create_by!(
        site_id: site.id,
        building_id: building.id,
        floor_id: floor.id,
        name: "D#{idx + 1}"
      )

      CamUnitConfig.find_or_create_by!(unit_id: unit.id) do |cfg|
        cfg.carpet_area_sqft = 900 + (idx * 20)
        cfg.cam_start_date = Date.current.beginning_of_year
      end

      unit
    end

    AccountGroup.seed_default_groups(site.id)
    Ledger.seed_default_ledgers(site.id)

    bank_ledger = Ledger.find_by(code: 'L-BANK', site_id: site.id)
    cash_ledger = Ledger.find_by(code: 'L-CASH', site_id: site.id)
    maint_ledger = Ledger.find_by(code: 'L-MAINT', site_id: site.id)
    salary_ledger = Ledger.find_by(code: 'L-SALARY', site_id: site.id)

    year = Date.current.year
    month = Date.current.month

    cam_bills = units.each_with_index.map do |unit, idx|
      CamUnitBill.find_or_create_by!(unit_id: unit.id, site_id: site.id, year: year, month: month) do |b|
        b.carpet_area_sqft = 900 + (idx * 20)
        b.daily_rate_per_sqft = 0.80
        b.active_days = 30
        b.base_amount = (b.carpet_area_sqft.to_f * b.daily_rate_per_sqft.to_f * b.active_days).round(2)
        b.gst_rate_percent = 18
        b.gst_amount = (b.base_amount.to_f * 0.18).round(2)
        b.total_amount = (b.base_amount.to_f + b.gst_amount.to_f).round(2)
        b.status = 'generated'
      end
    end

    10.times.each do |idx|
      bill = cam_bills[idx]
      CamReceipt.find_or_create_by!(bill_type: 'CamUnitBill', bill_id: bill.id, date: Date.current.beginning_of_month + idx.days) do |r|
        r.amount = ((bill.total_amount.to_f * 0.5) + idx * 10).round(2)
        r.reference_no = "RCPT-DEMO-#{idx + 1}"
      end
    end

    expense_categories = [
      'Security', 'Housekeeping', 'Electricity', 'DG Diesel', 'Water',
      'Lift AMC', 'Plumbing', 'Gardening', 'Admin', 'Repair'
    ]

    expense_categories.each_with_index do |cat, idx|
      CamMonthlyExpense.find_or_create_by!(project_id: project.id, site_id: site.id, year: year, month: month, category: cat) do |e|
        e.amount = 1500 + (idx * 350)
      end
    end

    invoices = 10.times.map do |idx|
      unit = units[idx]
      invoice_date = Date.current.beginning_of_month + idx.days

      invoice = AccountingInvoice.find_or_initialize_by(
        site_id: site.id,
        unit_id: unit.id,
        invoice_date: invoice_date,
        customer_name: "Demo Unit #{unit.name}",
        invoice_type: 'cam_charges'
      )

      if invoice.new_record?
        invoice.created_by = user
        invoice.status = 'sent'
        invoice.payment_mode = 'online'
        invoice.total_amount = 2000 + (idx * 150)
        invoice.subtotal = invoice.total_amount
        invoice.tax_amount = 0
        invoice.paid_amount = 0
        invoice.balance_amount = invoice.total_amount
        invoice.due_date = invoice_date + 10.days
        invoice.notes = 'Demo accounting invoice'
        invoice.save!
      end

      invoice
    end

    invoices.each_with_index do |invoice, idx|
      payment_number = "DEMO-PMT-#{site.id}-#{year}-#{month}-#{(idx + 1).to_s.rjust(2, '0')}"
      AccountingPayment.find_or_create_by!(
        payment_number: payment_number,
        site_id: site.id,
        unit_id: invoice.unit_id,
        accounting_invoice_id: invoice.id,
        payment_date: Date.current.beginning_of_month + idx.days,
        amount: (500 + idx * 50),
        payment_type: 'received'
      ) do |p|
        p.created_by = user
        p.received_by = user
        p.payment_mode = 'online'
        p.reference_number = "PMT-DEMO-#{idx + 1}"
        p.notes = 'Demo payment'
      end
    end

    invoices.each_with_index do |invoice, idx|
      IncomeEntry.find_or_create_by!(
        site_id: site.id,
        unit_id: invoice.unit_id,
        source_type: 'AccountingInvoice',
        source_id: invoice.id,
        received_date: Date.current.beginning_of_month + idx.days,
        amount: (700 + idx * 60)
      ) do |ie|
        ie.user_id = user.id
        ie.invoice_number = invoice.invoice_number
        ie.payment_mode = 'online'
        ie.reference_number = "INC-DEMO-#{idx + 1}"
        ie.status = 'received'
        ie.notes = 'Demo income entry'
      end
    end

    10.times.each do |idx|
      narration = "Demo manual JE #{idx + 1}"
      je = JournalEntry.find_or_initialize_by(site_id: site.id, entry_type: 'manual_demo', narration: narration)
      next if je.persisted?

      je.entry_date = Date.current.beginning_of_month + idx.days
      je.unit_id = units[idx].id
      je.created_by = user
      je.status = 'draft'
      je.save!

      amount = 1000 + (idx * 100)
      JournalEntryLine.create!(journal_entry_id: je.id, ledger_id: salary_ledger&.id || maint_ledger.id, entry_side: 'debit', amount: amount, description: "Demo expense #{idx + 1}", unit_id: units[idx].id)
      JournalEntryLine.create!(journal_entry_id: je.id, ledger_id: bank_ledger&.id || cash_ledger.id, entry_side: 'credit', amount: amount, description: "Demo bank outflow #{idx + 1}", unit_id: units[idx].id)

      je.reload
      je.post!(user)
    end

    puts "✔ Demo accounting data ready"
    puts "  Site ID: #{site.id}"
    puts "  Project ID: #{project.id}"
    puts "  Units: #{Unit.where(site_id: site.id).count}"
    puts "  CAM Bills: #{CamUnitBill.where(site_id: site.id, year: year, month: month).count}"
    puts "  CAM Receipts: #{CamReceipt.joins("INNER JOIN cam_unit_bills ON cam_unit_bills.id = receipts.bill_id AND receipts.bill_type = 'CamUnitBill'").where(cam_unit_bills: { site_id: site.id }).count}"
    puts "  Monthly Expenses: #{CamMonthlyExpense.where(site_id: site.id, year: year, month: month).count}"
    puts "  Invoices: #{AccountingInvoice.where(site_id: site.id).count}"
    puts "  Payments: #{AccountingPayment.where(site_id: site.id).count}"
    puts "  Income Entries: #{IncomeEntry.where(site_id: site.id).count}"
    puts "  Journal Entries: #{JournalEntry.where(site_id: site.id, entry_type: 'manual_demo').count}"
  end
end
