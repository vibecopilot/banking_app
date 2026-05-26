class InvoiceReceiptsController < ApplicationController
    include UserExt
before_action :authenticate_user!, if: :check_user ,  except: [:download_sample]
  before_action :api_user,except: [:download_sample]
  before_action :set_user,except: [:download_sample]
  before_action :set_invoice_receipt, only: %i[ show edit update destroy ]

  # GET /invoice_receipts or /invoice_receipts.json
  def index
    # @invoice_receipts = InvoiceReceipt.where.not(resource_type: "CamBill").ransack(params[:q]).result
    @invoice_receipts = InvoiceReceipt.where(site_id: @user.current_site_id).ransack(params[:q]).result

  end

  # GET /invoice_receipts/1 or /invoice_receipts/1.json
  def show
  end
def export
  if params[:ids]
    invoice_receipts = InvoiceReceipt.where(id: params[:ids]) 
    else
    invoice_receipts = InvoiceReceipt.where(site_id: @user.current_site_id) 
    end
    export_invoice_receipts(invoice_receipts) # Call the export method
    send_file 'invoice_receipts.xlsx', type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
  end
  def export_invoice_receipts(invoice_receipts)
  # Create a new Excel package
  Axlsx::Package.new do |p|
    # Add a worksheet
    p.workbook.add_worksheet(name: "Invoice Receipts") do |sheet|
      # Define the header row
      sheet.add_row ["ID", "Receipt Number", "Invoice Number", "Building ID", "Unit ID", "Address ID", 
                     "Payment Mode", "Amount Received", "Transaction/Cheque Number", "Bank Name", 
                     "Branch Name", "Payment Date", "Receipt Date", "Notes", "Created At", "Updated At", "CAM Bill ID"]
    
      invoice_receipts.each do |receipt|
        sheet.add_row [
          receipt.id,
          receipt.receipt_number,
          receipt.invoice_number,
          receipt.building_id,
          receipt.unit_id,
          receipt.address_id,
          receipt.payment_mode,
          receipt.amount_received,
          receipt.transaction_or_cheque_number,
          receipt.bank_name,
          receipt.branch_name,
          receipt.payment_date,
          receipt.receipt_date,
          receipt.notes,
          receipt.created_at,
          receipt.updated_at,
          receipt.cam_bill_id
        ]
      end
    end

    # Save the package to a file
    p.serialize('invoice_receipts.xlsx')
  end

  puts "Invoice receipts exported to invoice_receipts.xlsx"
end


    def import
    if params[:file].present?
      result = InvoiceReceipt.import(params[:file])

      render json: {
        message: 'Import process completed.',
        rows_added: result[:added_count],  # Accessing added_count correctly
        errors: result[:errors],          # This will contain the error details
        rows: result[:rows]                # This will contain the rows processed
      }, status: :ok
    else
      render json: {
        message: 'No file uploaded. Please upload a valid CSV or Excel file.'
      }, status: :bad_request
    end
  end
    def download_sample
    file_path = Rails.root.join('public', 'sample_files', 'invoice_receipts.xlsx')

    if File.exist?(file_path)
      send_file(
        file_path,
        filename: "invoice_receipts.xlsx",
        type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
      )
    else
      render json: { error: "Sample file not found" }, status: :not_found
    end
  end


  # GET /invoice_receipts/new
  def new
    @invoice_receipt = InvoiceReceipt.new
  end

  # GET /invoice_receipts/1/edit
  def edit
  end

  # POST /invoice_receipts or /invoice_receipts.json
  def create
    @invoice_receipt = InvoiceReceipt.new(invoice_receipt_params)
    @invoice_receipt.site_id = @user.current_site_id
    respond_to do |format|
      if @invoice_receipt.save
        format.html { redirect_to @invoice_receipt, notice: "Invoice receipt was successfully created." }
        format.json { render :show, status: :created, location: @invoice_receipt }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @invoice_receipt.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /invoice_receipts/1 or /invoice_receipts/1.json
  def update
    respond_to do |format|
      if @invoice_receipt.update(invoice_receipt_params)
        format.html { redirect_to @invoice_receipt, notice: "Invoice receipt was successfully updated." }
        format.json { render :show, status: :ok, location: @invoice_receipt }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @invoice_receipt.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /invoice_receipts/1 or /invoice_receipts/1.json
  def destroy
    @invoice_receipt.destroy
    respond_to do |format|
      format.html { redirect_to invoice_receipts_url, notice: "Invoice receipt was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_invoice_receipt
      @invoice_receipt = InvoiceReceipt.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def invoice_receipt_params
      params.require(:invoice_receipt).permit(:vendor_id,:receipt_number,:resource_type,:resource_id ,:invoice_number, :building_id, :unit_id, :address_id, :payment_mode, :amount_received, :transaction_or_cheque_number, :bank_name, :branch_name, :payment_date, :receipt_date, :notes,:cam_bill_id)
    end
end
