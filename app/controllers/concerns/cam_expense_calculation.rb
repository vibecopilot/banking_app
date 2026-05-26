# Shared expense calculation for CAM: CAM Monthly Expense + Journal Entry.
# Used by Api::CamReportsController (calculate_expense_allocation, etc.) and
# Api::CamMonthlyExpensesController (calculate_total) so totals stay consistent.
module CamExpenseCalculation
  # Returns { cam_total:, journal_total:, total: } for the period.
  # site_id: project_id for CAM monthly expenses, site_id for journal entries (same id).
  # categories: optional array; when present, filters only CAM monthly expenses by category (journal is always included in full).
  def calculate_period_expenses_breakdown(*args)
    if args.length >= 5
      year, start_month, end_month, site_id, categories = args
      start_date = Date.new(year, start_month, 1)
      end_date   = Date.new(year, end_month, -1)
    else
      start_date, end_date, site_id, categories = args
    end

    categories = Array(categories).reject(&:blank?)

    cam_scope = CamMonthlyExpense.where(
      year: start_date.year..end_date.year,
      month: start_date.month..end_date.month
    )

    cam_scope = cam_scope.where(project_id: site_id) if site_id.present?
    cam_scope = cam_scope.where(category: categories) if categories.present?
    # Exclude all GST-related categories
    gst_keywords = ['%CGST%', '%SGST%', '%IGST%', '%GST%']
    gst_keywords.each { |keyword| cam_scope = cam_scope.where("category NOT LIKE ?", keyword) }

    cam_total = cam_scope.sum(:amount).to_f

    # Journal Entry Expenses (exclude GST account groups and ledgers)
    # Use expense_month/expense_year when available, fallback to entry_date
    # Only include expense-type account groups (excludes asset/income/liability debits)
    je_scope = JournalEntryLine.joins(:journal_entry, ledger: :account_group)
      .where(journal_entries: { status: %w[posted manual] })
      .merge(JournalEntry.by_expense_date_range(start_date, end_date))
      .where(entry_side: 'debit')
      .where(account_groups: { group_type: 'expense' })
    je_scope = je_scope.where(journal_entries: { site_id: site_id }) if site_id.present?
    # Exclude GST-related account groups and ledgers
    je_scope = je_scope.where.not(account_groups: { name: ['GST Input', 'GST Output'] })
    gst_keywords.each { |keyword| je_scope = je_scope.where("ledgers.name NOT LIKE ?", keyword) }
    
    journal_total = je_scope.sum(:amount).to_f

    {
      cam_total: cam_total,
      journal_total: journal_total,
      total: cam_total + journal_total
    }
  end
end
