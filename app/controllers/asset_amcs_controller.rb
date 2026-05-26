class AssetAmcsController < ApplicationController
  before_action :set_asset_amc, only: %i[ show edit update destroy ]
  include UserExt
  # GET /asset_amcs or /asset_amcs.json
  # def index
  #   @user = User.find_by(api_key: params[:token])
  #   #use site for current selected site
  #   @asset_amcs = AssetAmc.ransack(site_asset_site_id_eq: @user&.site&.id).result.ransack(params[:q]).result
  # end
def index
  @user = User.find_by(api_key: params[:token])
  base_scope = AssetAmc
                 .joins(:site_asset)
                 .where(site_assets: { site_id: @user&.current_site_id })

  @q = base_scope.ransack(params[:q])

  @asset_amcs = @q.result
                  .order(created_at: :desc)
                  .page(params[:page])
                  .per(params[:per_page] || 100)
end



  # GET /asset_amcs/1 or /asset_amcs/1.json
  def show
  end

  # GET /asset_amcs/new
  def new
    @asset_amc = AssetAmc.new
  end

  # GET /asset_amcs/1/edit
  def edit
  end

  # POST /asset_amcs or /asset_amcs.json
  def create
    @asset_amc = AssetAmc.new(asset_amc_params)

    respond_to do |format|
      if @asset_amc.save
        save_attachfiles(:terms, "AmcTerm")
        save_attachfiles(:amc_contacts, "AmcContact")
        save_attachfiles(:amc_invoices, "AmcInvoice")

        format.html { redirect_to @asset_amc, notice: "Asset amc was successfully created." }
        format.json { render :show, status: :created, location: @asset_amc }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @asset_amc.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /asset_amcs/1 or /asset_amcs/1.json
  def update
    respond_to do |format|
      if @asset_amc.update(asset_amc_params)
        save_attachfiles(:terms, "AmcTerm")
        save_attachfiles(:amc_contacts, "AmcContact")
        save_attachfiles(:amc_invoices, "AmcInvoice")

        format.html { redirect_to @asset_amc, notice: "Asset amc was successfully updated." }
        format.json { render :show, status: :ok, location: @asset_amc }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @asset_amc.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /asset_amcs/1 or /asset_amcs/1.json
  def destroy
    @asset_amc.destroy
    respond_to do |format|
      format.html { redirect_to asset_amcs_url, notice: "Asset amc was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_asset_amc
      @asset_amc = AssetAmc.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def asset_amc_params
      params.require(:asset_amc).permit(
        :vendor_id, :asset_id, :start_date, :end_date, :frequency,
        :first_service, :visits, :amc_cost, :remarks,
        amc_contacts_attributes: [:id, :name, :phone, :email, :designation, :_destroy],
        amc_invoices_attributes: [:id, :invoice_number, :amount, :invoice_date, :document, :_destroy]
      )
    end

    def save_attachfiles(param_key, relation_type)
      return unless params[param_key].present?
      Array(params[param_key]).each do |file|
        Attachfile.create(image: file, relation: relation_type, relation_id: @asset_amc.id, active: 1)
      end
    end
end
