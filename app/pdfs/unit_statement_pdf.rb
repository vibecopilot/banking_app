class UnitStatementPdf < Prawn::Document
  def initialize(company, unit, invoices, payments, summary, expenses, from_date, to_date)
    super(page_size: 'A4', margin: 30)

    @company = company
    @unit = unit
    @summary = summary
    @expenses = expenses
    @from_date = from_date
    @to_date = to_date

    header
    move_down 10
    unit_info
    move_down 15
    summary_blocks
    move_down 15
    expense_table
    move_down 20
    footer
  end

  # 🏢 HEADER (DYNAMIC)
  def header
    text @company[:company_name], size: 14, style: :bold, align: :center

    full_address = [
      @company[:address],
      "#{@company[:city]}, #{@company[:state]} - #{@company[:pincode]}"
    ].compact.join(", ")

    text full_address, size: 9, align: :center

    move_down 3
    text "GST: #{@company[:gst_number]}   |   PAN: #{@company[:pan_number]}", size: 9, align: :center

    move_down 5
    text "STATEMENT OF COMMON AREA MAINTENANCE", size: 12, style: :bold, align: :center
    text "Period: #{@from_date} to #{@to_date}", size: 10, align: :center
  end

  # 🏠 UNIT INFO
  def unit_info
    table([
            ["Flat No:", @unit.name, "Date:", Date.today.to_s],
            ["Building:", @unit.building&.name, "Floor:", @unit.floor&.name]
    ], width: bounds.width) do
      cells.borders = []
      columns(0).font_style = :bold
      columns(2).font_style = :bold
    end
  end

  def summary_blocks
    data = [
      ["A", "Total Invoiced", @summary[:total_invoiced]],
      ["B", "Total Paid", @summary[:total_paid]],
      ["C", "Balance", @summary[:outstanding_balance]],
      ["D", "Maintenance Charges", maintenance_total],
      ["E", "Other Income", 0],
      ["F", "Final Balance (C - D + E)", final_balance]
    ]

    table(data, width: bounds.width) do
      row(0..-1).columns(0).font_style = :bold
      columns(2).align = :right
    end
  end

  # 📊 EXPENSE TABLE (FULLY DYNAMIC)
  def expense_table
    text "Expense Breakdown", style: :bold
    move_down 5

    data = [["Sr No", "Particular", "Amount"]]

    @expenses.each_with_index do |exp, i|
      data << [i + 1, exp[:name], exp[:amount]]
    end

    table(data, header: true, width: bounds.width) do
      row(0).font_style = :bold
      row(0).background_color = 'DDDDDD'
      columns(2).align = :right
    end
  end

  def maintenance_total
    @expenses.sum { |e| e[:amount].to_f }
  end

  def final_balance
    @summary[:outstanding_balance].to_f - maintenance_total
  end

  def bank_details
    move_down 10
    text "Bank Details", style: :bold

    table([
            ["Bank Name", @company[:bank_name]],
            ["Account No", @company[:account_number]],
            ["IFSC Code", @company[:ifsc_code]],
            ["Branch", @company[:branch_name]]
    ], width: bounds.width) do
      cells.borders = []
      columns(0).font_style = :bold
    end
  end

  def footer
    move_down 20
    text "1) This is system generated statement.", size: 9
    text "2) Any adjustments will reflect in next cycle.", size: 9
  end
end
