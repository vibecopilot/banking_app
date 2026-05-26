class Pms::SuppliersController < ApplicationController

  before_action :set_pms_supplier, only: [:show, :edit, :update, :destroy, :reviews]
  layout 'asset_creation_layout'
  include UserExt
  before_action :authenticate_user!
  before_action :api_user
  before_action :set_user

  # GET /pms/suppliers
  # GET /pms/suppliers.json
  def index
    @pms_suppliers = Pms::Supplier.where(site_id: current_user.selected_site_id).order("company_name asc")
      respond_to do |format|
       format.html { render layout: 'pms_new_layout' }
      end
  end

  # GET /pms/suppliers/1
  # GET /pms/suppliers/1.json
  def show
  end

  # GET /pms/suppliers/new
  def new
    @pms_supplier = Pms::Supplier.new
  end

  # GET /pms/suppliers/1/edit
  def edit
  end

  # POST /pms/suppliers
  # POST /pms/suppliers.json
  def create
   #render json:params and return
    @pms_supplier = Pms::Supplier.new(pms_supplier_params)
    respond_to do |format|
      @pms_supplier.supplier_type = params[:pms_supplier][:supplier_type]
      if @pms_supplier.save
        if params[:attachments].present? 
          params[:attachments].each do |doc|
            bsf = Attachfile.create(document: doc, relation: "Pms::Supplier", relation_id: @pms_supplier.id, active: 1)
            bsf.save
          end
        end 
        format.html do
          if params[:custom_redirect].present?
           redirect_to params[:custom_redirect]
          else
           redirect_to @pms_supplier, notice: 'Supplier was successfully created.'
          end
        end
        format.json { render :show, status: :created, location: @pms_supplier }
        format.js do
          flash.now[:success_message] = "Successfully created the supplier"
        end
      else
        format.html do
          redirect_to "/pms/suppliers/new", alert: @pms_supplier.errors.full_messages
        end
        format.json { render json: @pms_supplier.errors, status: :unprocessable_entity }
        format.js { flash.now[:error_message] = @pms_supplier.error.full_messages }
      end
    end
  end

  # PATCH/PUT /pms/suppliers/1
  # PATCH/PUT /pms/suppliers/1.json
  def update
    respond_to do |format|
      @pms_supplier.supplier_type = params[:pms_supplier][:supplier_type]
      if @pms_supplier.update(pms_supplier_params)
        format.html { redirect_to params[:custom_redirect] || @pms_supplier, notice: 'Supplier was successfully updated.' }
        format.json { render :show, status: :ok, location: @pms_supplier }
      else
        format.html { render :edit }
        format.json { render json: @pms_supplier.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pms/suppliers/1
  # DELETE /pms/suppliers/1.json
  def destroy
    @pms_supplier.update(active: false)
    respond_to do |format|
      format.html { redirect_to params[:custom_redirect] || pms_suppliers_url, notice: 'Supplier was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def reviews
    @pms_supplier_ratings = @pms_supplier.ratings
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_pms_supplier
      @pms_supplier = Pms::Supplier.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def pms_supplier_params
      params.require(:pms_supplier).permit(
                                            :first_name,
                                            :last_name,
                                            :email,
                                            :company_name,
                                            :gstin_number,
                                            :pan_number,
                                            :address,
                                            :mobile1,
                                            :mobile2,
                                            :country,
                                            :state,
                                            :city, 
                                            :pincode,
                                            :address2,
                                            :account_name,
                                            :account_number,
                                            :bank_branch_name,
                                            :ifsc_code,
                                            :supplier_type => [],
                                            pms_text_fields_attributes: [ :id, :name, :value, :_destroy ],
                                            :pms_supplier_contacts_attributes => [ :id, :first_name, :last_name, :mobile1, :mobile2, :email1, :email2 ]
                                          ).merge(company_id: current_user.company_id, site_id: current_user.selected_site_id)
    end


end
