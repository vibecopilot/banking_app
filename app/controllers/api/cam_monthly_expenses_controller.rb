module Api
  class CamMonthlyExpensesController < ApplicationController
    protect_from_forgery with: :null_session

    def index
      year = params[:year].to_i
      month = params[:month].to_i
      end_month = params[:end_month].present? ? params[:end_month].to_i : month
      site_id = params[:project_id] || params[:site_id]

      # GST categories to exclude
      gst_keywords = ['%CGST%', '%SGST%', '%IGST%', '%GST%']

      # --- CAM Monthly Expenses (EXCLUDING GST) ---
      cam_scope = CamMonthlyExpense.where(year: year, month: month..end_month)
      gst_keywords.each { |keyword| cam_scope = cam_scope.where("category NOT LIKE ?", keyword) }
      cam_scope = cam_scope.where(project_id: site_id) if site_id.present?
      cam_rows = cam_scope.order(:category)

      # --- Journal Entry Ledger Expenses (debit lines grouped by ledger) ---
      # EXCLUDING GST ledgers (GST Input, GST Output, etc.)
      # Use expense_month/expense_year when available, fallback to entry_date
      je_line_scope = JournalEntryLine.joins(:journal_entry, ledger: :account_group)
        .where(journal_entries: { status: ['posted', 'manual'] })
        .merge(JournalEntry.by_expense_period(year, month, end_month))
        .where(entry_side: 'debit')
        .where(account_groups: { group_type: 'expense' })
      
      # Exclude GST-related account groups and ledger names
      je_line_scope = je_line_scope.where.not(account_groups: { name: [
        'GST Input', 'GST Output'
      ] })
      gst_ledger_keywords = ['%CGST%', '%SGST%', '%IGST%', '%GST%']
      gst_ledger_keywords.each { |kw| je_line_scope = je_line_scope.where("ledgers.name NOT LIKE ?", kw) }
      
      je_line_scope = je_line_scope.where(journal_entries: { site_id: site_id }) if site_id.present?

      je_by_ledger = je_line_scope
        .group('ledgers.id', 'ledgers.name')
        .sum(:amount)

      ledger_rows = je_by_ledger.map do |(ledger_id, ledger_name), amount|
        {
          id: nil,
          category: ledger_name,
          amount: amount.to_f.round(2),
          year: year,
          month: month,
          source: 'journal_entry',
          ledger_id: ledger_id,
          ledger_name: ledger_name
        }
      end.sort_by { |r| r[:category] }

      # --- Build per-ledger journal entries detail (excluding GST) ---
      je_details = {}
      if ledger_rows.any?
        ledger_ids = ledger_rows.map { |r| r[:ledger_id] }
        detail_lines = JournalEntryLine.includes(journal_entry: [:site, :created_by])
          .joins(:journal_entry, ledger: :account_group)
          .where(journal_entries: { status: ['posted', 'manual'] })
          .merge(JournalEntry.by_expense_period(year, month, end_month))
          .where(entry_side: 'debit')
          .where(account_groups: { group_type: 'expense' })
          .where(ledger_id: ledger_ids)
        
        # Exclude GST-related account groups and ledger names
        detail_lines = detail_lines.where.not(account_groups: { name: [
          'GST Input', 'GST Output'
        ] })
        gst_ledger_keywords.each { |kw| detail_lines = detail_lines.where("ledgers.name NOT LIKE ?", kw) }
        
        detail_lines = detail_lines.where(journal_entries: { site_id: site_id }) if site_id.present?

        detail_lines.each do |line|
          je = line.journal_entry
          ledger_name = line.ledger.name
          je_details[ledger_name] ||= []
          je_details[ledger_name] << {
            id: je.id,
            entry_number: je.entry_number,
            entry_date: je.entry_date,
            status: je.status,
            amount: line.amount.to_f.round(2),
            narration: je.narration
          }
        end
        # Deduplicate by je id within each ledger
        je_details.each { |k, v| je_details[k] = v.uniq { |e| e[:id] } }
      end

      render json: {
        data: cam_rows,
        ledger_expenses: ledger_rows,
        journal_entry_details: je_details
      }
    end

    def create
      me = CamMonthlyExpense.new(expense_params)
      if me.save
        render json: { data: me }, status: :created
      else
        render json: { error: me.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def update
      me = CamMonthlyExpense.find(params[:id])
      if me.update(expense_params)
        render json: { data: me }, status: :ok
      else
        render json: { error: me.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def destroy
      me = CamMonthlyExpense.find(params[:id])
      me.destroy
      render json: { data: true }
    end

    def calculate_total
      # Support both year/month/end_month AND start_date/end_date params
      if params[:year].present?
        yr = params[:year].to_i
        sm = (params[:month].presence || 1).to_i
        em = (params[:end_month].presence || sm).to_i
        start_date = Date.new(yr, sm, 1)
        end_date   = Date.new(yr, em, -1)
      else
        start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : Date.today.beginning_of_month
        end_date   = params[:end_date].present? ? Date.parse(params[:end_date]) : start_date.end_of_month
      end

      categories = params[:categories] || []
      if categories.is_a?(String)
        categories = categories.split(',').map(&:strip).reject(&:blank?)
      end
      categories = Array(categories).reject(&:blank?)

      site_id = params[:project_id] || params[:site_id]

      # --- CAM Monthly Expenses ---
      cam_scope = CamMonthlyExpense.where(year: start_date.year, month: start_date.month..end_date.month)
      # Handle cross-year range
      if start_date.year != end_date.year
        conditions = []
        (start_date.year..end_date.year).each do |y|
          ms = y == start_date.year ? start_date.month : 1
          me = y == end_date.year ? end_date.month : 12
          conditions << "(year = #{y} AND month BETWEEN #{ms} AND #{me})"
        end
        cam_scope = CamMonthlyExpense.where(conditions.join(' OR '))
      end
      cam_scope = cam_scope.where(project_id: site_id) if site_id.present?
      
      # Exclude GST categories
      gst_keywords = ['%CGST%', '%SGST%', '%IGST%', '%GST%']
      gst_keywords.each { |keyword| cam_scope = cam_scope.where("category NOT LIKE ?", keyword) }

      all_cam_categories = cam_scope.group(:category).sum(:amount).transform_values { |v| v.to_f.round(2) }

      # --- Journal Entry Expenses (debit lines grouped by ledger name) ---
      # EXCLUDING GST account groups
      # Use expense_month/expense_year when available, fallback to entry_date
      je_line_scope = JournalEntryLine.joins(:journal_entry, ledger: :account_group)
        .where(journal_entries: { status: ['posted', 'manual'] })
        .merge(JournalEntry.by_expense_date_range(start_date, end_date))
        .where(entry_side: 'debit')
        .where(account_groups: { group_type: 'expense' })
      
      # Exclude GST-related account groups and ledger names
      je_line_scope = je_line_scope.where.not(account_groups: { name: [
        'GST Input', 'GST Output'
      ] })
      ['%CGST%', '%SGST%', '%IGST%', '%GST%'].each { |kw| je_line_scope = je_line_scope.where("ledgers.name NOT LIKE ?", kw) }
      
      je_line_scope = je_line_scope.where(journal_entries: { site_id: site_id }) if site_id.present?

      all_je_categories = je_line_scope.group('ledgers.name').sum(:amount).transform_values { |v| v.to_f.round(2) }

      # --- Merge all categories (excluding GST) ---
      all_categories = {}
      all_cam_categories.each { |k, v| all_categories[k] = v }
      all_je_categories.each { |k, v| all_categories[k] = (all_categories[k] || 0) + v }

      # --- Calculate filtered total ---
      if categories.present?
        cam_total = cam_scope.where(category: categories).sum(:amount).to_f
        je_total  = je_line_scope.where(ledgers: { name: categories }).sum(:amount).to_f
        total = cam_total + je_total
      else
        total = all_categories.values.sum
      end

      # binding.pry
      

      render json: {
        total: total.round(2),
        start_date: start_date,
        end_date: end_date,
        categories: all_categories,
        selected_categories: categories
      }
    end
    
    private

    def expense_params
      params.require(:monthly_expense).permit(:project_id, :year, :month, :category, :amount)
    end
  end
end
