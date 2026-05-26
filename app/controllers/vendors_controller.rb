class VendorsController < ApplicationController
  include UserExt
  layout 'basic'
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_vendor, only: %i[ show edit update destroy ]
  before_action :load_vendor_data, only: [:new, :create, :edit, :update]

  # GET /vendors or /vendors.json
  def index
    @vendors = Vendor.where(site_id: @user.current_site_id).ransack(params[:q]).result
  end

  # GET /vendors/1 or /vendors/1.json
  def show
  end

  # GET /vendors/new
  def new
    @vendor = Vendor.new
  end

  def all_vendors
  @vendors = Vendor.all

  respond_to do |format|
    format.html # This will render a view (e.g., `app/views/vendors/all_vendors.html.erb`)
    format.json { render json: @vendors }
  end
end

  # GET /vendors/1/edit
  def edit
  end

  # POST /vendors or /vendors.json
  def create
    @vendor = Vendor.new(vendor_params)
    @vendor.site_id = @user.current_site_id

    # Find the correct GenericSubInfo records for supplier and category
    supplier = GenericSubInfo.find_by(id: params[:vendor][:vendor_supplier_id])
    category = GenericSubInfo.find_by(id: params[:vendor][:vendor_categories_id])

    @vendor.supplier = supplier if supplier
    @vendor.category = category if category

    respond_to do |format|
      if @vendor.save
        if params[:attachments].present? 
          params[:attachments].each do |doc|
            Attachfile.create(image: doc, relation: "VendorImaage", relation_id: @vendor.id, active: 1)
          end
        end

        format.html { redirect_to @vendor, notice: "Vendor was successfully created." }
        format.json { render :show, status: :created, location: @vendor }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @vendor.errors, status: :unprocessable_entity }
      end
    end
  end

  def import
    @file = params[:file]
    @uploadds = Vendor.import(@file, @user)
    respond_to do |format|
      format.html {
        redirect_to request.referrer + "#" , notice: "Successfully imported vendors"
      }
      format.json { render json: @uploadds }
    end
  end

  # PATCH/PUT /vendors/1 or /vendors/1.json
  def update
    respond_to do |format|
      if @vendor.update(vendor_params)
        format.html { redirect_to @vendor, notice: "Vendor was successfully updated." }
        format.json { render :show, status: :ok, location: @vendor }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @vendor.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /vendors/1 or /vendors/1.json
  def destroy
    @vendor.destroy
    respond_to do |format|
      format.html { redirect_to vendors_url, notice: "Vendor was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_vendor
      @vendor = Vendor.find(params[:id])
    end

    def load_vendor_data
      supplier_info = GenericInfo.find_by(info_type: 'vendor_supplier', site_id: @user.current_site_id)
      category_info = GenericInfo.find_by(info_type: 'vendor_categories', site_id: @user.current_site_id)
      
      @vendor_suppliers = supplier_info ? GenericSubInfo.where(generic_info_id: supplier_info.id) : []
      @vendor_categories = category_info ? GenericSubInfo.where(generic_info_id: category_info.id) : []
    end

    # Only allow a list of trusted parameters through.
    def vendor_params
      params.require(:vendor).permit(:vendor_name, :company_name, :mobile, :email, :site_id, :vtype, :notes,:first_name, :last_name, :secondary_mobile, :secondary_email,
      :gstin_number, :pan_number, :address, :active, :country, :state,:website_link,:aggrement_start_date,:aggremenet_end_date,:spoc_person,
      :city, :pincode, :address2, :account_name, :account_number,:active,:status,
      :bank_branch_name, :ifsc_code, :website_url, :district,
      :vendor_supplier_id, :vendor_categories_id)
    end
end
