module Api
  class CamIncomeExpenseSummaryController < ApplicationController
    protect_from_forgery with: :null_session

    def show
      year = params[:year].to_i
      month = params[:month].to_i
      from = Date.new(year, month, 1)
      to = from.end_of_month

      bills_total = CamUnitBill.where(year: year, month: month).sum(:total_amount)
      receipts_total = CamReceipt.where(date: from..to).sum(:amount)

      # Get CAM manually entered expenses (exclude GST categories)
      expenses_scope = CamMonthlyExpense.where(year: year, month: month)
      
      # Exclude GST-related categories using LIKE
      gst_keywords = ['%CGST%', '%SGST%', '%IGST%', '%GST%']
      gst_keywords.each { |keyword| expenses_scope = expenses_scope.where("category NOT LIKE ?", keyword) }
      
      expenses_scope = expenses_scope.where(project_id: params[:project_id]) if params[:project_id].present?
      cam_expenses_total = expenses_scope.sum(:amount)

      # Get journal entry expenses (exclude GST account groups)
      # Only include expense-type account groups (excludes asset/income/liability debits)
      je_line_scope = JournalEntryLine
        .joins(:journal_entry, ledger: :account_group)
        .where(journal_entries: { site_id: params[:project_id] || nil })
        .where(entry_side: 'debit')
        .where(account_groups: { group_type: 'expense' })
        .where('DATE(journal_entries.created_at) BETWEEN ? AND ?', from, to)
        .where.not(account_groups: { name: ['GST Input', 'GST Output'] })
      # Also exclude ledgers with GST-related names
      ['%CGST%', '%SGST%', '%IGST%', '%GST%'].each { |kw| je_line_scope = je_line_scope.where("ledgers.name NOT LIKE ?", kw) }
      
      je_expenses_total = je_line_scope.sum(:amount)
      
      # Total expenses = CAM expenses + Journal Entry expenses (excluding GST)
      total_expenses = cam_expenses_total + je_expenses_total
      
      # Apex calculations (30% to company)
      apex_percentage = 0.30
      apex_contribution = (bills_total * apex_percentage).to_d
      building_fund_available = (bills_total - apex_contribution).to_d
      
      # Final balance after expenses
      balance_fund_available = (building_fund_available - total_expenses).to_d

      # binding.pry
      
      render json: { 
        data: { 
          # Income section
          bills_total: bills_total.to_d,
          receipts_total: receipts_total.to_d,
          
          # Apex calculation
          advance_maintenance_received: bills_total.to_d,
          apex_contribution_percentage: (apex_percentage * 100).to_i,
          apex_contribution: apex_contribution,
          building_fund_available: building_fund_available,
          
          # Expense section
          cam_expenses: cam_expenses_total.to_d,
          ledger_expenses: je_expenses_total.to_d,
          total_expenses: total_expenses.to_d,
          
          # Net calculations
          net_income: (bills_total - total_expenses).to_d,
          balance_fund_available: balance_fund_available
        }, 
        meta: { 
          year: year, 
          month: month,
          period: "#{Date::MONTHNAMES[month]} #{year}"
        } 
      }
    rescue ArgumentError
      render json: { error: 'Invalid year/month' }, status: :unprocessable_entity
    end
  end
end
