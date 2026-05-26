class CamBillsController < ApplicationController
  include UserExt
  before_action :authenticate_user!, if: :check_user, except: [:pdf, :invoice_pdf, :bill_detail_pdf]
  before_action :api_user, except: [:pdf, :invoice_pdf, :bill_detail_pdf]
  before_action :set_user, except: [:pdf, :invoice_pdf, :bill_detail_pdf]
  before_action :set_cam_bill, only: %i[ show edit update destroy ]

  # GET /cam_bills or /cam_bills.json
  def index
    @q = CamBill.where(site_id: @user.selected_site_id).ransack(params[:q]) # Initialize Ransack with filter params
    base_scope = @q.result.order(created_at: :desc).page(params[:page]).per(params[:per_page] || 100)
    @cam_bills =  base_scope

    respond_to do |format|
      format.html # Render HTML by default
      format.json # Automatically renders index.json.jbuilder
    end
  end

  def pdf
    @cam_bill = CamBill.find_by(id: params[:id])
    render pdf: 'qr_codes',
      disposition: 'attachment',
      dpi: 72,
    margin: {
      top: 10,
      bottom: 10,
      left: 5,
      right: 5
    },
      template: 'cam_bills/pdf.html.erb',
      layout: 'layouts/pdf_layout.html.erb',
      formats: :pdf,
      encoding: 'utf8'
    return
  end

  # New detailed PDF with all cam bill information
  def bill_detail_pdf
    @cam_bill = CamBill.includes(:cam_bill_charges, :user, :unit, :building, :site, :address).find_by(id: params[:id])

    unless @cam_bill
      render json: { error: "Cam Bill not found" }, status: :not_found and return
    end

    render pdf: "cam_bill_#{@cam_bill.invoice_number || @cam_bill.id}",
      disposition: 'inline',
      dpi: 96,
      page_size: 'A4',
    margin: {
      top: 15,
      bottom: 15,
      left: 10,
      right: 10
    },
      template: 'cam_bills/bill_detail_pdf.html.erb',
      layout: 'layouts/pdf_layout.html.erb',
      formats: :pdf,
      encoding: 'utf8'
  end

  def invoice_pdf
    @invoice_receipt = InvoiceReceipt.find_by(id: params[:id])
    # @cam_bill = CamBill.find_by(id: params[:id])
    render pdf: 'qr_codes',
      disposition: 'attachment',
      dpi: 72,
      template: 'cam_bills/invoice_pdf.html.erb',
      layout: 'layouts/pdf_layout.html.erb',
      formats: :pdf,
      encoding: 'utf8'
    return
  end

  # GET /cam_bills/1 or /cam_bills/1.json
  def show
  end

  # GET /cam_bills/new
  def new
    @cam_bill = CamBill.new
  end

  # GET /cam_bills/1/edit
  def edit
  end

  # POST /cam_bills or /cam_bills.json
  def create
    @cam_bill = CamBill.new(cam_bill_params)
    @cam_bill.site_id = @user.selected_site_id
    user_id = UserSite.find_by(unit_id: params[:unit_id], ownership: "Owner").try(:user_id)
    @cam_bill.user_id = user_id
    respond_to do |format|
      if @cam_bill.save
        format.html { redirect_to @cam_bill, notice: "Cam bill was successfully created." }
        format.json { render :show, status: :created, location: @cam_bill }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @cam_bill.errors, status: :unprocessable_entity }
      end
    end
  end


  def import
    file = params[:file]
    unless file.content_type.in?(["application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "application/vnd.ms-excel", "text/csv"])
      render json: { error: "Unsupported file type. Please upload an Excel or CSV file." }, status: :unprocessable_entity
      return
    end

    result = CamBill.import(file, @user.selected_site_id)
    render json: { message: "Import successful", created_records: result }, status: :ok
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def export
    # Parse ids from the query string (e.g., "1,2,3")
    ids_param = params[:ids] # Expecting params[:ids] as "1,2,3"
    cam_bill_ids = ids_param.present? ? ids_param.tr('[]', '').split(',').map(&:strip) : []
    @cam_bills = CamBill.includes(:cam_bill_charges, :unit, :building, :user, :address).where(id: cam_bill_ids)
    respond_to do |format|
      # JSON response
      format.json do
        render json: @cam_bills.map { |bill|
          bill.as_json(
            only: [
              :id, :status, :recall_reason, :unit_id, :user_id, :bill_date, :due_date, :floor_id,
              :total_amount, :created_by, :sub_amount, :invoice_type, :invoice_address_id,
              :invoice_number, :building_id, :flat_id, :due_amount, :due_amount_interst, :note,
              :supply_date, :bill_period_end_date, :bill_period_start_date, :payment_status
            ]
          ).merge(
            unit_name: bill.unit&.name,
            building_name: bill.building&.name,
            floor_name: bill.unit&.floor&.name,
            user_name: bill.user&.name,
            cam_bill_charges: bill.cam_bill_charges.map { |charge|
              charge.as_json(
                only: [
                  :id, :charge_id, :charge_amount, :sub_amount, :cgst_amount, :igst_amount,
                  :sgst_amount, :description, :discount_percent, :cgst_rate, :sgst_rate,
                  :igst_rate, :quantity, :unit, :rate, :hsn_id, :taxable_value, :total,
                  :total_value, :discount_amount
                ]
              )
            }
          )
        }
      end
      # Excel response
      format.xlsx do
        send_data generate_excel(@cam_bills),
          filename: "CamBills_#{Time.now.strftime('%Y%m%d%H%M%S')}.xlsx",
          type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
      end
    end
  end


  # PATCH/PUT /cam_bills/1 or /cam_bills/1.json
  def update
    respond_to do |format|
      if @cam_bill.update(cam_bill_params)
        format.html { redirect_to @cam_bill, notice: "Cam bill was successfully updated." }
        format.json { render :show, status: :ok, location: @cam_bill }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @cam_bill.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cam_bills/1 or /cam_bills/1.json
  def destroy
    @cam_bill.destroy
    respond_to do |format|
      format.html { redirect_to cam_bills_url, notice: "Cam bill was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def download_sample
    file_path = Rails.root.join('public', 'sample_files', 'import_cam_bill.xlsx')

    if File.exist?(file_path)
      send_file(
        file_path,
        filename: "import_cam_bill.xlsx",
        type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
      )
    else
      render json: { error: "Sample file not found" }, status: :not_found
    end
  end

  private

  # Generate Excel file using caxlsx
  def generate_excel(cam_bills)
    package = Axlsx::Package.new
    workbook = package.workbook

    workbook.add_worksheet(name: "Cam Bills") do |sheet|
      # Add headers matching import format
      sheet.add_row [
        # Cam Bill fields
        "unit_name", "unit_id", "building_name", "building_id", "floor_name", "floor_id",
        "user_id", "bill_date", "due_date", "supply_date", "bill_period_start_date", "bill_period_end_date",
        "total_amount", "sub_amount", "due_amount", "due_amount_interest",
        "status", "payment_status", "invoice_number", "invoice_type", "invoice_address_id",
        "note", "recall_reason", "created_by",
        # Charge fields
        "charge_id", "charge_amount", "charge_sub_amount", "cgst_amount", "igst_amount",
        "sgst_amount", "description", "discount_percent", "cgst_rate", "sgst_rate",
        "igst_rate", "quantity", "charge_unit", "rate", "hsn_id",
        "taxable_value", "charge_total", "total_value", "discount_amount"
      ]

      # Add data rows
      cam_bills.each do |bill|
        first_charge = true
        bill.cam_bill_charges.each do |charge|
          # Show CamBill details only for the first charge row
          sheet.add_row [
            # Cam Bill fields
            first_charge ? bill.unit&.name : nil,
            first_charge ? bill.unit_id : nil,
            first_charge ? bill.building&.name : nil,
            first_charge ? bill.building_id : nil,
            first_charge ? bill.unit&.floor&.name : nil,
            first_charge ? bill.floor_id : nil,
            first_charge ? bill.user_id : nil,
            first_charge ? bill.bill_date : nil,
            first_charge ? bill.due_date : nil,
            first_charge ? bill.supply_date : nil,
            first_charge ? bill.bill_period_start_date : nil,
            first_charge ? bill.bill_period_end_date : nil,
            first_charge ? bill.total_amount : nil,
            first_charge ? bill.sub_amount : nil,
            first_charge ? bill.due_amount : nil,
            first_charge ? bill.due_amount_interst : nil,
            first_charge ? bill.status : nil,
            first_charge ? bill.payment_status : nil,
            first_charge ? bill.invoice_number : nil,
            first_charge ? bill.invoice_type : nil,
            first_charge ? bill.invoice_address_id : nil,
            first_charge ? bill.note : nil,
            first_charge ? bill.recall_reason : nil,
            first_charge ? bill.created_by : nil,
            # Charge fields
            charge.charge_id,
            charge.charge_amount,
            charge.sub_amount,
            charge.cgst_amount,
            charge.igst_amount,
            charge.sgst_amount,
            charge.description,
            charge.discount_percent,
            charge.cgst_rate,
            charge.sgst_rate,
            charge.igst_rate,
            charge.quantity,
            charge.unit,
            charge.rate,
            charge.hsn_id,
            charge.taxable_value,
            charge.total,
            charge.total_value,
            charge.discount_amount
          ]
          first_charge = false # After the first row for this bill, suppress CamBill details
        end

        # If the CamBill has no charges, ensure it still shows as a standalone row
        if bill.cam_bill_charges.empty?
          sheet.add_row [
            # Cam Bill fields
            bill.unit&.name,
            bill.unit_id,
            bill.building&.name,
            bill.building_id,
            bill.unit&.floor&.name,
            bill.floor_id,
            bill.user_id,
            bill.bill_date,
            bill.due_date,
            bill.supply_date,
            bill.bill_period_start_date,
            bill.bill_period_end_date,
            bill.total_amount,
            bill.sub_amount,
            bill.due_amount,
            bill.due_amount_interst,
            bill.status,
            bill.payment_status,
            bill.invoice_number,
            bill.invoice_type,
            bill.invoice_address_id,
            bill.note,
            bill.recall_reason,
            bill.created_by,
            # Empty charge fields
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
          ]
        end
      end
    end

    package.to_stream.read
  end


  # Use callbacks to share common setup or constraints between actions.
  def set_cam_bill
    @cam_bill = CamBill.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def cam_bill_params
    params.require(:cam_bill).permit(:status, :recall_reason, :unit_id, :user_id, :bill_date, :due_date,:floor_id, :total_amount, :created_by, :sub_amount, :payment_status, :invoice_type, :invoice_address_id, :invoice_number, :building_id, :flat_id, :due_amount, :due_amount_interst, :note,:supply_date,:bill_period_end_date,:bill_period_start_date,
                                     cam_bill_charges_attributes: [
                                       :id,
                                       :charge_id,
                                       :charge_amount,
                                       :sub_amount,
                                       :cgst_amount,
                                       :igst_amount,
                                       :sgst_amount,
                                       :description,
                                       :discount_percent,
                                       :cgst_rate,
                                       :sgst_rate,
                                       :igst_rate,
                                       :quantity,
                                       :unit,
                                       :rate,
                                       :hsn_id,
                                       :taxable_value,
                                       :total,
                                       :total_value,
                                       :discount_amount,
                                       :_destroy
    ])
  end
end
