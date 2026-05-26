class InvoiceSetupsController < ApplicationController

      include UserExt
    before_action :authenticate_user!, if: :check_user
    before_action :api_user
    before_action :set_user
    before_action :set_invoice_setup, only: %i[ show edit update destroy ]
    skip_before_action :verify_authenticity_token, only:  %i[ :upload_logo  get_logo]


  # GET /invoice_setups or /invoice_setups.json
  def index
    @invoice_setups = InvoiceSetup.all
  end

  # GET /invoice_setups/1 or /invoice_setups/1.json
  def show
  end

  # GET /invoice_setups/new
  def new
    @invoice_setup = InvoiceSetup.new
  end

  # GET /invoice_setups/1/edit
  def edit
  end

  # POST /invoice_setups or /invoice_setups.json
  def create
    @invoice_setup = InvoiceSetup.new(invoice_setup_params)
    @invoice_setup.created_by = @user.id
    @invoice_setup.site_id = @user.current_site_id

    respond_to do |format|
      if @invoice_setup.save
        format.html { redirect_to @invoice_setup, notice: "Invoice setup was successfully created." }
        format.json { render :show, status: :created, location: @invoice_setup }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @invoice_setup.errors, status: :unprocessable_entity }
      end
    end
  end
def get_logo
  logo = Attachfile.where(
      relation: "InvoiceLogo",
      relation_id: @user.current_site_id,
      active: 1
    ).last
  if logo.present?
   respond_to do |format|
      format.json { render json: { attachment: logo ,logo_url: logo.document_url} }
    end
  else
    respond_to do |format|
      format.json { render json: { error: "Attachment not Added" } }
    end
    end
    
end 
def upload_logo
  if params[:attachment].present?
    attachfile = Attachfile.create(
      image: params[:attachment],
      relation: "InvoiceLogo",
      relation_id: @user.current_site_id,
      active: 1
    )
    respond_to do |format|
      format.json { render json: { attachment: attachfile ,logo_url: attachfile.document_url}, status: :created }
    end
  else
    respond_to do |format|
      format.json { render json: { error: "Attachment not provided" }, status: :unprocessable_entity }
    end
  end
end


  # PATCH/PUT /invoice_setups/1 or /invoice_setups/1.json
  def update
    respond_to do |format|
      if @invoice_setup.update(invoice_setup_params)
        format.html { redirect_to @invoice_setup, notice: "Invoice setup was successfully updated." }
        format.json { render :show, status: :ok, location: @invoice_setup }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @invoice_setup.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /invoice_setups/1 or /invoice_setups/1.json
  def destroy
    @invoice_setup.destroy
    respond_to do |format|
      format.html { redirect_to invoice_setups_url, notice: "Invoice setup was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_invoice_setup
      @invoice_setup = InvoiceSetup.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def invoice_setup_params
      params.require(:invoice_setup).permit(:prefix, :next_number, :auto_generate, :site_id, :online_payment_allowed)
    end
end
