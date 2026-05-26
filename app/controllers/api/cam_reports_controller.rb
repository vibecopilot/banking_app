module Api
  class CamReportsController < ApplicationController
    # protect_from_forgery with: :null_session
    skip_forgery_protection

    # POST /api/cam/calculate_expense_allocation
    # Calculate expense allocation per unit based on days and area
    def calculate_expense_allocation
      year = params[:year].to_i
      start_month = params[:month].to_i
      end_month = params[:end_month].present? ? params[:end_month].to_i : start_month
      site_id = params[:site_id] || params[:project_id]
      categories = params[:categories] || []

      if categories.is_a?(String)
        categories = categories.split(',').map(&:strip).reject(&:blank?)
      end
      categories = Array(categories).reject(&:blank?)

      total_expense = calculate_period_expenses(year, start_month, end_month, site_id, categories)

      unit_configs = get_unit_configs_for_site(site_id)

      # 🔥 PRELOAD UNITS (Fix N+1)
      unit_ids = unit_configs.map(&:unit_id)
      units_map = Unit.where(id: unit_ids).index_by(&:id)

      period_start = Date.new(year, start_month, 1)
      period_end = Date.new(year, end_month, -1)
      total_days_in_period = (period_end - period_start + 1).to_i

      rows = []
      total_active_days = 0
      total_area = 0
      total_area_days = 0

      unit_configs.each do |config|

        cam_start = config.cam_start_date || period_start
        active_start = [cam_start, period_start].max
        active_days = active_start <= period_end ? (period_end - active_start + 1).to_i : 0

        area = config.carpet_area_sqft.to_f
        area_days = active_days * area

        total_active_days += active_days
        total_area += area
        total_area_days += area_days

        # 🔥 No query here now
        unit = units_map[config.unit_id]
        unit_name = unit&.name || unit&.flat || "Unit #{config.unit_id}"

        rows << {
          unit_id: config.unit_id,
          flat: unit_name,
          unit_name: unit_name,
          area: area,
          activeDays: active_days,
          areaDays: area_days,
          daysShare: 0
        }
      end

      rows.each do |row|
        row[:daysShare] =
          total_active_days > 0 ?
          (total_expense * row[:activeDays].to_f / total_active_days).round(2) : 0
      end

      render json: {
        data: {
          rows: rows,
          totals: {
            days: total_active_days,
            area: total_area.round(2),
            areaDays: total_area_days.round(2),
            expense: total_expense.round(2),
            daysInMonth: total_days_in_period
          }
        }
      }
    end

    # POST /api/cam/calculate_income_allocation
    # Calculate income allocation per unit based on days
    def calculate_income_allocation
      year = params[:year].to_i
      start_month = params[:month].to_i
      end_month = params[:end_month].present? ? params[:end_month].to_i : start_month
      site_id = params[:site_id] || params[:project_id]
      categories = params[:categories] || []

      # Normalize categories
      if categories.is_a?(String)
        categories = categories.split(',').map(&:strip).reject(&:blank?)
      end
      categories = Array(categories).reject(&:blank?)

      # Total income
      total_income = calculate_period_income(year, start_month, end_month, site_id, categories)

      # Unit configs filtered by site
      unit_configs = get_unit_configs_for_site(site_id)

      # 🔥 PRELOAD UNITS (Fix N+1)
      unit_ids = unit_configs.map(&:unit_id)
      units_map = Unit.where(id: unit_ids).index_by(&:id)

      period_start = Date.new(year, start_month, 1)
      period_end   = Date.new(year, end_month, -1)

      rows = []
      total_active_days = 0
      total_area = 0

      unit_configs.each do |config|

        cam_start = config.cam_start_date || period_start
        active_start = [cam_start, period_start].max

        active_days =
          active_start <= period_end ?
          (period_end - active_start + 1).to_i : 0

        area = config.carpet_area_sqft.to_f

        total_active_days += active_days
        total_area += area

        # 🔥 No DB query here
        unit = units_map[config.unit_id]

        unit_name = unit&.name || unit&.flat || "Unit #{config.unit_id}"

        rows << {
          unit_id: config.unit_id,
          flat: unit_name,
          unit_name: unit_name,
          area: area,
          activeDays: active_days,
          areaDays: active_days * area,
          incomeShare: 0
        }
      end

      # Allocate income
      rows.each do |row|
        row[:incomeShare] =
          total_active_days > 0 ?
          (total_income * row[:activeDays].to_f / total_active_days).round(2) : 0
      end

      render json: {
        data: {
          rows: rows,
          totals: {
            days: total_active_days,
            area: total_area.round(2),
            income: total_income.round(2)
          }
        }
      }
    end

    # POST /api/cam/calculate_income_vs_expense
    # Calculate income vs expense comparison per unit
    def calculate_income_vs_expense
      year = params[:year].to_i
      start_month = params[:month].to_i
      end_month = params[:end_month].present? ? params[:end_month].to_i : start_month
      site_id = params[:site_id] || params[:project_id]

      # Expense categories
      expense_categories = params[:expense_categories] || params[:categories] || []
      if expense_categories.is_a?(String)
        expense_categories = expense_categories.split(',').map(&:strip).reject(&:blank?)
      end
      expense_categories = Array(expense_categories).reject(&:blank?)

      # Income categories
      income_categories = params[:income_categories] || []
      if income_categories.is_a?(String)
        income_categories = income_categories.split(',').map(&:strip).reject(&:blank?)
      end
      income_categories = Array(income_categories).reject(&:blank?)

      # Totals
      total_expense = calculate_period_expenses(year, start_month, end_month, site_id, expense_categories)
      total_income  = calculate_period_income(year, start_month, end_month, site_id, income_categories)

      unit_configs = get_unit_configs_for_site(site_id)

      # 🔥 FIX N+1 (Load Units Once)
      unit_ids = unit_configs.map(&:unit_id)
      units_map = Unit.where(id: unit_ids).index_by(&:id)

      period_start = Date.new(year, start_month, 1)
      period_end   = Date.new(year, end_month, -1)

      rows = []
      total_active_days = 0
      total_area = 0

      unit_configs.each do |config|

        cam_start = config.cam_start_date || period_start
        active_start = [cam_start, period_start].max

        active_days =
          active_start <= period_end ?
          (period_end - active_start + 1).to_i : 0

        area = config.carpet_area_sqft.to_f

        total_active_days += active_days
        total_area += area

        # No query here
        unit = units_map[config.unit_id]

        unit_name = unit&.name || unit&.flat || "Unit #{config.unit_id}"

        rows << {
          unit_id: config.unit_id,
          flat: unit_name,
          unit_name: unit_name,
          area: area,
          activeDays: active_days,
          areaDays: active_days * area,
          daysShare: 0,
          incomeShare: 0,
          outstanding: 0
        }
      end

      # Calculate shares
      rows.each do |row|
        next if total_active_days == 0

        expense_share = total_expense * row[:activeDays].to_f / total_active_days
        income_share  = total_income  * row[:activeDays].to_f / total_active_days

        row[:daysShare]   = expense_share.round(2)
        row[:incomeShare] = income_share.round(2)
        row[:outstanding] = (expense_share - income_share).round(2)
      end

      render json: {
        data: {
          rows: rows,
          totals: {
            days: total_active_days,
            area: total_area.round(2),
            income: total_income.round(2),
            expense: total_expense.round(2),
            net: (total_income - total_expense).round(2)
          }
        }
      }
    end

    # GET /api/cam/income_by_category
    def income_by_category
      # Support both from_date/to_date and year/month/end_month params
      if params[:year].present?
        yr = params[:year].to_i
        sm = (params[:month].presence || 1).to_i
        em = (params[:end_month].presence || sm).to_i
        from_date = Date.new(yr, sm, 1).to_s
        to_date   = Date.new(yr, em, -1).to_s
      else
        from_date = params[:from_date]
        to_date = params[:to_date]
      end
      site_id = params[:site_id]

      # Income from invoices
      invoice_scope = AccountingInvoice.all
      invoice_scope = invoice_scope.where('invoice_date >= ?', from_date) if from_date.present?
      invoice_scope = invoice_scope.where('invoice_date <= ?', to_date) if to_date.present?
      invoice_scope = invoice_scope.where(site_id: site_id) if site_id.present?

      invoices_by_type = invoice_scope.group(:invoice_type).sum(:total_amount)

      # Income from income entries
      income_scope = IncomeEntry.all
      income_scope = income_scope.where('received_date >= ?', from_date) if from_date.present?
      income_scope = income_scope.where('received_date <= ?', to_date) if to_date.present?
      income_scope = income_scope.where(site_id: site_id) if site_id.present?

      income_by_source = income_scope.group(:source_type).sum(:amount)

      # Income from journal entry credit lines (by ledger name, exclude GST)
      je_line_scope = JournalEntryLine.joins(:journal_entry, ledger: :account_group)
        .where(entry_side: 'credit')
        .where(journal_entries: { status: ['posted', 'manual'] })
      # Use expense_month/expense_year when available, fallback to entry_date
      if from_date.present? && to_date.present?
        je_line_scope = je_line_scope.merge(JournalEntry.by_expense_date_range(Date.parse(from_date.to_s), Date.parse(to_date.to_s)))
      else
        je_line_scope = je_line_scope.where('journal_entries.entry_date >= ?', from_date) if from_date.present?
        je_line_scope = je_line_scope.where('journal_entries.entry_date <= ?', to_date) if to_date.present?
      end
      je_line_scope = je_line_scope.where(journal_entries: { site_id: site_id }) if site_id.present?
      # Exclude GST-related account groups and ledgers
      je_line_scope = je_line_scope.where.not(account_groups: { name: ['GST Input', 'GST Output'] })
      ['%CGST%', '%SGST%', '%IGST%', '%GST%'].each { |kw| je_line_scope = je_line_scope.where("ledgers.name NOT LIKE ?", kw) }

      je_by_ledger = je_line_scope.group('ledgers.name').sum(:amount)

      # Combine
      by_category = {}
      invoices_by_type.each { |k, v| by_category[k || 'Invoices'] = v.to_f.round(2) }
      income_by_source.each { |k, v| by_category[k || 'Income Entries'] = (by_category[k || 'Income Entries'] || 0) + v.to_f.round(2) }
      je_by_ledger.each { |k, v| by_category[k || 'Journal Entries'] = (by_category[k || 'Journal Entries'] || 0) + v.to_f.round(2) }

      render json: { data: by_category }
    end

    # GET /api/cam/expense_by_category
    def expense_by_category
      year = params[:year].to_i
      start_month = params[:month].to_i
      end_month = params[:end_month].present? ? params[:end_month].to_i : start_month
      site_id = params[:site_id] || params[:project_id]

      # GST categories to exclude
      gst_keywords = ['%CGST%', '%SGST%', '%IGST%', '%GST%']

      # --- CAM Monthly Expenses by category (exclude GST) ---
      cam_scope = CamMonthlyExpense
        .where(year: year)
        .where(month: start_month..end_month)
      cam_scope = cam_scope.where(project_id: site_id) if site_id.present?
      gst_keywords.each { |keyword| cam_scope = cam_scope.where("category NOT LIKE ?", keyword) }

      expenses = cam_scope
        .group(:category)
        .sum(:amount)
        .transform_values { |v| v.to_f.round(2) }

      # --- Journal Entry Expenses by ledger name (exclude GST) ---
      period_start = Date.new(year, start_month, 1)
      period_end   = Date.new(year, end_month, -1)

      # Use expense_month/expense_year when available, fallback to entry_date
      # Only include expense-type account groups (excludes asset/income/liability debits)
      je_line_scope = JournalEntryLine.joins(:journal_entry, ledger: :account_group)
        .where(journal_entries: { status: ['posted', 'manual'] })
        .merge(JournalEntry.by_expense_period(year, start_month, end_month))
        .where(entry_side: 'debit')
        .where(account_groups: { group_type: 'expense' })
      je_line_scope = je_line_scope.where(journal_entries: { site_id: site_id }) if site_id.present?
      # Exclude GST-related account groups and ledgers
      je_line_scope = je_line_scope.where.not(account_groups: { name: ['GST Input', 'GST Output'] })
      gst_keywords.each { |keyword| je_line_scope = je_line_scope.where("ledgers.name NOT LIKE ?", keyword) }

      je_by_ledger = je_line_scope
        .group('ledgers.name')
        .sum(:amount)
        .transform_values { |v| v.to_f.round(2) }

      # Merge journal entry categories into expenses (combine if same name)
      je_by_ledger.each do |ledger_name, amount|
        expenses[ledger_name] = (expenses[ledger_name] || 0) + amount
      end

      render json: { data: expenses }
    end

    # GET /api/cam/daily_income_report
    def daily_income_report
      from_date = params[:from_date]
      to_date = params[:to_date]
      site_id = params[:site_id]

      # Income entries grouped by date
      scope = IncomeEntry.all
      scope = scope.where('received_date >= ?', from_date) if from_date.present?
      scope = scope.where('received_date <= ?', to_date) if to_date.present?
      scope = scope.where(site_id: site_id) if site_id.present?

      daily_data = scope.group(:received_date).sum(:amount).transform_values { |v| v.to_f.round(2) }

      # Also include payments from invoices
      payment_scope = AccountingPayment.all
      payment_scope = payment_scope.where('payment_date >= ?', from_date) if from_date.present?
      payment_scope = payment_scope.where('payment_date <= ?', to_date) if to_date.present?

      payment_scope.group(:payment_date).sum(:amount).each do |date, amt|
        daily_data[date] = (daily_data[date] || 0) + amt.to_f.round(2)
      end

      # Format as array
      result = daily_data.map { |date, amount| { date: date, amount: amount } }.sort_by { |r| r[:date] }

      render json: { data: result, total: daily_data.values.sum.round(2) }
    end

    # GET /api/cam/daily_expense_report
    def daily_expense_report
      # binding.pry
      year = params[:year].to_i
      start_month = params[:month].to_i
      end_month = params[:end_month].present? ? params[:end_month].to_i : start_month
      site_id = params[:site_id] || params[:project_id]

      # Monthly expenses don't have daily granularity, so we distribute evenly
      period_start = Date.new(year, start_month, 1)
      period_end = Date.new(year, end_month, -1)
      total_days = (period_end - period_start + 1).to_i

      total_expense = calculate_period_expenses(year, start_month, end_month, site_id, [])
      daily_expense = total_days > 0 ? (total_expense / total_days).round(2) : 0

      # Generate daily data
      result = []
      (period_start..period_end).each do |date|
        result << { date: date.to_s, amount: daily_expense }
      end

      render json: { data: result, total: total_expense.round(2), daily_average: daily_expense }
    end

    # GET /api/cam/unit_wise_income_summary
    def unit_wise_income_summary
      from_date = params[:from_date]
      to_date = params[:to_date]
      site_id = params[:site_id]

      # Get income entries by unit
      scope = IncomeEntry.all
      scope = scope.where('received_date >= ?', from_date) if from_date.present?
      scope = scope.where('received_date <= ?', to_date) if to_date.present?
      scope = scope.where(site_id: site_id) if site_id.present?

      by_unit = scope.group(:unit_id).sum(:amount).transform_values { |v| v.to_f.round(2) }

      # Get invoices by unit
      invoice_scope = AccountingInvoice.all
      invoice_scope = invoice_scope.where('invoice_date >= ?', from_date) if from_date.present?
      invoice_scope = invoice_scope.where('invoice_date <= ?', to_date) if to_date.present?
      invoice_scope = invoice_scope.where(site_id: site_id) if site_id.present?

      invoice_scope.group(:unit_id).sum(:total_amount).each do |unit_id, amt|
        by_unit[unit_id] = (by_unit[unit_id] || 0) + amt.to_f.round(2)
      end

      # Add unit names
      units_map = Unit.where(id: by_unit.keys).index_by(&:id)
      result = by_unit.map do |unit_id, amount|
        unit = units_map[unit_id]
        {
          unit_id: unit_id,
          unit_name: unit&.name || unit&.flat || "Unit #{unit_id}",
          amount: amount
        }
      end

      render json: { data: result, total: by_unit.values.sum.round(2) }
    end

    # GET /api/cam/unit_wise_expense_summary
    def unit_wise_expense_summary
      year = params[:year].to_i
      start_month = params[:month].to_i
      end_month = params[:end_month].present? ? params[:end_month].to_i : start_month
      site_id = params[:site_id] || params[:project_id]

      # Get total expense
      total_expense = calculate_period_expenses(year, start_month, end_month, site_id, [])

      # Get unit configs - filter through units table since unit_cam_configs doesn't have site_id
      unit_configs = get_unit_configs_for_site(site_id)

      period_start = Date.new(year, start_month, 1)
      period_end = Date.new(year, end_month, -1)

      total_active_days = 0
      units_data = []

      unit_configs.each do |config|
        cam_start = config.cam_start_date || period_start
        active_start = [cam_start, period_start].max
        active_days = active_start <= period_end ? (period_end - active_start + 1).to_i : 0
        total_active_days += active_days

        unit_ids = unit_configs.map(&:unit_id)
        units_map = Unit.where(id: unit_ids).index_by(&:id)
        unit = units_map[config.unit_id]

        units_data << {
          unit_id: config.unit_id,
          unit_name: unit&.name || unit&.flat || "Unit #{config.unit_id}",
          active_days: active_days
        }
      end

      # Calculate expense share
      result = units_data.map do |u|
        u[:amount] = total_active_days > 0 ? (total_expense * u[:active_days].to_f / total_active_days).round(2) : 0
        u
      end

      render json: { data: result, total: total_expense.round(2) }
    end

    # GET /api/cam/monthly_income
    def monthly_income
      year = params[:year].to_i
      month = params[:month].to_i
      site_id = params[:site_id]

      from_date = Date.new(year, month, 1)
      to_date = Date.new(year, month, -1)

      # Get income from various sources - use income_month/year when available
      income_entries = IncomeEntry.by_income_period(year, month)
      income_entries = income_entries.where(site_id: site_id) if site_id.present?

      by_category = income_entries.group(:source_type).sum(:amount).transform_values { |v| v.to_f.round(2) }

      # Include payments
      payments = AccountingPayment.where(payment_date: from_date..to_date)
      payments_total = payments.sum(:amount).to_f.round(2)
      by_category['Payments'] = payments_total if payments_total > 0

      result = by_category.map { |category, amount| { category: category, amount: amount } }

      render json: { data: result }
    end

    # GET /api/cam/monthly_income/total
    def monthly_income_total
      year = params[:year].to_i
      start_month = params[:month].to_i
      end_month = params[:end_month].present? ? params[:end_month].to_i : start_month
      site_id = params[:site_id]
      categories = params[:categories] || []

      # Support array passed as comma-separated string or actual array
      if categories.is_a?(String)
        categories = categories.split(',').map(&:strip).reject(&:blank?)
      end
      categories = Array(categories).reject(&:blank?)

      total = calculate_period_income(year, start_month, end_month, site_id, categories)

      render json: {
        total: total.round(2),
        year: year,
        start_month: start_month,
        end_month: end_month,
        selected_categories: categories
      }
    end

    # GET /api/cam/detailed_income_summary
    def detailed_income_summary
      from_date = params[:from_date]
      to_date = params[:to_date]
      site_id = params[:site_id]

      # Use IncomeEntry as single source of truth for all income
      # This avoids double-counting since invoice payments auto-create IncomeEntry records
      income_scope = IncomeEntry.all
      if from_date.present? && to_date.present?
        income_scope = income_scope.by_income_date_range(Date.parse(from_date.to_s), Date.parse(to_date.to_s))
      else
        income_scope = income_scope.where('received_date >= ?', from_date) if from_date.present?
        income_scope = income_scope.where('received_date <= ?', to_date) if to_date.present?
      end
      income_scope = income_scope.where(site_id: site_id) if site_id.present?
      
      # Total income from all sources
      total_income = income_scope.sum(:amount).to_f.round(2)

      # Breakdown by source type (CAM Bill, Invoice Payment, etc.)
      by_category = {}
      income_scope.group(:source_type).sum(:amount).each do |k, v| 
        by_category[k || 'Other'] = v.to_f.round(2) 
      end

      # Additional stats
      by_payment_mode = {}
      income_scope.group(:payment_mode).sum(:amount).each do |k, v|
        by_payment_mode[k || 'Unknown'] = v.to_f.round(2)
      end

      by_status = {}
      income_scope.group(:status).sum(:amount).each do |k, v|
        by_status[k || 'pending'] = v.to_f.round(2)
      end

      render json: {
        data: {
          total_income: total_income,
          by_category: by_category,
          by_payment_mode: by_payment_mode,
          by_status: by_status,
          entry_count: income_scope.count
        },
        meta: {
          from_date: from_date,
          to_date: to_date,
          note: "Income entries include auto-created entries from invoice payments"
        }
      }
    end

    # GET /api/cam/unit_cam_statement
    # Returns comprehensive CAM statement for a unit including income, expenses, apex calculations
    def unit_cam_statement
      # Accept either year/month or start_date/end_date
      if params[:year].present? && params[:month].present?
        year = params[:year].to_i
        month = params[:month].to_i
        from = Date.new(year, month, 1)
        to = from.end_of_month
      else
        from = params[:start_date].present? ? Date.parse(params[:start_date]) : Date.current.beginning_of_month
        to = params[:end_date].present? ? Date.parse(params[:end_date]) : Date.current.end_of_month
        year = from.year
        month = from.month
      end

      unit_id = params[:unit_id]

      # Unit details
      unit = Unit.find(unit_id)
      unit_name = unit&.name || unit&.flat || "Unit #{unit_id}"

      # Derive site_id from unit if not provided in params
      site_id = params[:site_id] || params[:project_id] || unit.site_id

      # Income: Bills issued to unit (query across all months in date range)
      # Keep for receipts calculation
      bills_scope = CamUnitBill.where(unit_id: unit_id)
      
      # Handle cross-year and multi-month ranges
      if from.year != to.year
        conditions = []
        (from.year..to.year).each do |y|
          ms = y == from.year ? from.month : 1
          me = y == to.year ? to.month : 12
          conditions << "(year = #{y} AND month BETWEEN #{ms} AND #{me})"
        end
        bills_scope = bills_scope.where(conditions.join(' OR '))
      else
        bills_scope = bills_scope.where(year: from.year, month: from.month..to.month)
      end
      
      bills_scope = bills_scope.where(site_id: site_id) if site_id.present?

      # Get advance amount from unit config (user-entered advance amount) — per-unit
      unit_config = CamUnitConfig.find_by(unit_id: unit_id)
      advance_amount = unit_config&.advance_amount.to_d

      # Apex calculations (30% transfer to company) - based on advance_amount only
      apex_percentage = 0.30
      apex_contribution = (advance_amount * apex_percentage).to_d
      building_fund_available = (advance_amount - apex_contribution).to_d

      # Receipts/Payments from unit (join through CamUnitBill)
      receipts_scope = CamReceipt
        .joins("LEFT JOIN cam_unit_bills ON cam_unit_bills.id = receipts.bill_id AND receipts.bill_type = 'CamUnitBill'")
        .where(date: from..to)
        .where("cam_unit_bills.unit_id = ?", unit_id)
      receipts_scope = receipts_scope.where("cam_unit_bills.site_id = ?", site_id) if site_id.present?
      receipts_total = receipts_scope.sum(:amount).to_d

      # Get total site income from IncomeEntry (single source of truth for all income)
      # This will be allocated proportionally using unit_share (same as expenses)
      total_site_income = IncomeEntry.where(site_id: site_id)
        .by_income_date_range(from, to)
        .sum(:amount).to_d

      # Get CAM expenses (exclude GST) - query across all months in date range
      cam_expenses_scope = CamMonthlyExpense.all
      cam_expenses_scope = cam_expenses_scope.where('project_id = ? OR project_id IS NULL', site_id) if site_id.present?
      
      # Handle cross-year and multi-month ranges
      if from.year != to.year
        conditions = []
        (from.year..to.year).each do |y|
          ms = y == from.year ? from.month : 1
          me = y == to.year ? to.month : 12
          conditions << "(year = #{y} AND month BETWEEN #{ms} AND #{me})"
        end
        cam_expenses_scope = cam_expenses_scope.where(conditions.join(' OR '))
      else
        cam_expenses_scope = cam_expenses_scope.where(year: from.year, month: from.month..to.month)
      end
      
      gst_keywords = ['%CGST%', '%SGST%', '%IGST%', '%GST%']
      gst_keywords.each { |keyword| cam_expenses_scope = cam_expenses_scope.where("category NOT LIKE ?", keyword) }
      
      # Total CAM expenses (before per-unit allocation)
      total_cam_expenses_all = cam_expenses_scope.sum(:amount).to_f
      cam_expense_breakdown_all = cam_expenses_scope.group(:category).sum(:amount).transform_values { |v| v.to_f.round(2) }

      # Get journal entry expenses (exclude GST account groups and ledger names)
      # Use expense_month/expense_year when available, fallback to entry_date
      # Only include expense-type account groups (excludes asset/income/liability debits)
      je_line_scope = JournalEntryLine
        .joins(:journal_entry, ledger: :account_group)
        .where(journal_entries: { site_id: site_id || nil })
        .merge(JournalEntry.by_expense_date_range(from, to))
        .where(entry_side: 'debit')
        .where(account_groups: { group_type: 'expense' })
        .where.not(account_groups: { name: ['GST Input', 'GST Output'] })
      gst_keywords.each { |kw| je_line_scope = je_line_scope.where("ledgers.name NOT LIKE ?", kw) }
      
      total_je_expenses_all = je_line_scope.sum(:amount).to_f
      je_breakdown_all = je_line_scope.group('account_groups.name').sum(:amount).transform_values { |v| v.to_f.round(2) }

      # Detailed breakdown: account_group -> ledger_name -> amount
      je_detail_all = je_line_scope.group('account_groups.name', 'ledgers.name').sum(:amount)
      je_grouped_detail_all = {}
      je_detail_all.each do |(group_name, ledger_name), amount|
        je_grouped_detail_all[group_name] ||= {}
        je_grouped_detail_all[group_name][ledger_name] = amount.to_f.round(2)
      end

      # Calculate unit's share using days-based allocation (same as expense allocation page)
      unit_configs = get_unit_configs_for_site(site_id)
      total_days_in_period = (to - from + 1).to_i

      total_active_days = 0
      unit_active_days = 0

      unit_configs.each do |config|
        cam_start = config.cam_start_date || from
        active_start = [cam_start, from].max
        active_days = active_start <= to ? (to - active_start + 1).to_i : 0
        total_active_days += active_days
        unit_active_days = active_days if config.unit_id.to_s == unit_id.to_s
      end

      # Apply unit's share to expenses
      unit_share = total_active_days > 0 ? (unit_active_days.to_f / total_active_days) : 0

      # Apply unit's share to income (distributed proportionally, same as expenses)
      allocated_other_income = (total_site_income * unit_share).round(2).to_d

      # Total income = advance_amount (per-unit) + allocated other income
      total_income = advance_amount + allocated_other_income

      cam_expense_breakdown = cam_expense_breakdown_all.transform_values { |v| (v * unit_share).round(2) }
      total_cam_expenses = (total_cam_expenses_all * unit_share).round(2).to_d

      je_breakdown = je_breakdown_all.transform_values { |v| (v * unit_share).round(2) }
      total_je_expenses = (total_je_expenses_all * unit_share).round(2).to_d

      # Apply unit share to detailed ledger breakdown
      je_grouped_detail = {}
      je_grouped_detail_all.each do |group_name, ledgers|
        je_grouped_detail[group_name] = ledgers.transform_values { |v| (v * unit_share).round(2) }
      end

      # Total expenses
      total_expenses = (total_cam_expenses + total_je_expenses).to_d

      # Society Maintenance Charges (percentage from BillingConfiguration, respects enable/disable toggle)
      billing_config = BillingConfiguration.find_by(site_id: site_id)
      society_maintenance_percent = billing_config&.management_fee_percentage.to_d
      society_maintenance_amount = society_maintenance_percent > 0 ? (total_expenses * society_maintenance_percent / 100).round(2).to_d : 0

      # Grand total with society charges
      grand_total_expenses = total_expenses + society_maintenance_amount

      # Balance calculations
      balance_fund_available = (building_fund_available - grand_total_expenses + allocated_other_income).to_d
      net_income = (total_income - grand_total_expenses).to_d

      render json: {
        data: {
          # Unit Information
          unit: {
            id: unit_id,
            name: unit_name,
            period: from == to ? from.strftime("%B %Y") : "#{from.strftime('%B %d, %Y')} - #{to.strftime('%B %d, %Y')}"
          },
          
          # Income Section
          # advance_amount = from CamUnitConfig (per-unit fixed advance)
          # allocated_other_income = total site income × unit_share (distributed like expenses)
          income: {
            advance_maintenance_received: advance_amount,
            other_income: allocated_other_income,
            total_site_income: total_site_income,
            total_income: total_income,
            receipts_total: receipts_total
          },
          
          # Apex Contribution Section (30% on advance amount only)
          apex: {
            advance_maintenance_received: advance_amount,
            total_income: advance_amount,
            contribution_percentage: (apex_percentage * 100).to_i,
            contribution_amount: apex_contribution,
            building_fund_available: building_fund_available
          },
          
          # Expense Section
          expenses: {
            cam_expenses: total_cam_expenses,
            cam_breakdown: cam_expense_breakdown,
            ledger_expenses: total_je_expenses,
            ledger_breakdown: je_breakdown,
            ledger_detail: je_grouped_detail,
            subtotal: total_expenses,
            society_maintenance_percent: society_maintenance_percent.to_f,
            society_maintenance_amount: society_maintenance_amount,
            total: grand_total_expenses
          },
          
          # Balance Calculation
          balance: {
            building_fund: building_fund_available,
            less_total_expenses: grand_total_expenses,
            balance_fund_available: balance_fund_available,
            net_income: net_income
          }
        },
        meta: {
          start_date: from.to_s,
          end_date: to.to_s,
          period: from == to ? from.strftime("%B %Y") : "#{from.strftime('%B %d, %Y')} - #{to.strftime('%B %d, %Y')}",
          generated_at: Time.current.iso8601
        }
      }
    rescue => e
      render json: { error: e.message }, status: :unprocessable_entity
    end

    private

    # Helper to get unit_cam_configs filtered by site
    # Since unit_cam_configs doesn't have site_id, we join through units table
    def get_unit_configs_for_site(site_id)
      return CamUnitConfig.all unless site_id.present?
      CamUnitConfig
      .joins("INNER JOIN units ON units.id = unit_cam_configs.unit_id")
      .where("units.site_id = ?", site_id)
    end

    def calculate_period_expenses(year, start_month, end_month, site_id, categories)
      period_start = Date.new(year, start_month, 1)
      period_end   = Date.new(year, end_month, -1)

      # --- CAM Monthly Expenses (exclude GST categories) ---
      cam_scope = CamMonthlyExpense
        .where(year: year)
        .where(month: start_month..end_month)
      cam_scope = cam_scope.where(project_id: site_id) if site_id.present?
      cam_scope = cam_scope.where(category: categories) if categories.present?
      # Exclude all GST-related categories
      gst_keywords = ['%CGST%', '%SGST%', '%IGST%', '%GST%']
      gst_keywords.each { |keyword| cam_scope = cam_scope.where("category NOT LIKE ?", keyword) }
      cam_total = cam_scope.sum(:amount).to_f

      # --- Journal Entry Expenses (debit lines, exclude GST account groups) ---
      # Use expense_month/expense_year when available, fallback to entry_date
      # Only include expense-type account groups (excludes asset/income/liability debits)
      je_line_scope = JournalEntryLine.joins(:journal_entry, ledger: :account_group)
        .where(journal_entries: { status: ['posted', 'manual'] })
        .merge(JournalEntry.by_expense_period(year, start_month, end_month))
        .where(entry_side: 'debit')
        .where(account_groups: { group_type: 'expense' })
      je_line_scope = je_line_scope.where(journal_entries: { site_id: site_id }) if site_id.present?
      # Filter by ledger name when categories are provided
      je_line_scope = je_line_scope.where(ledgers: { name: categories }) if categories.present?
      # Exclude GST-related account groups and ledgers
      je_line_scope = je_line_scope.where.not(account_groups: { name: ['GST Input', 'GST Output'] })
      gst_keywords.each { |keyword| je_line_scope = je_line_scope.where("ledgers.name NOT LIKE ?", keyword) }
      journal_total = je_line_scope.sum(:amount).to_f
      cam_total + journal_total
    end

    def calculate_period_income(year, start_month, end_month, site_id, categories)
      period_start = Date.new(year, start_month, 1)
      period_end = Date.new(year, end_month, -1)

      # Use income_month/income_year when available, fallback to received_date
      income_scope = IncomeEntry.by_income_period(year, start_month, end_month)
      income_scope = income_scope.where(site_id: site_id) if site_id.present?
      income_scope = income_scope.where(source_type: categories) if categories.present? && categories.any?
      income_scope.sum(:amount).to_f
    end
  end
end
