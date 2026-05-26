class InventoriesController < ApplicationController
  include UserExt
  layout 'basic'
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_inventory, only: %i[ show edit update destroy ]

  # GET /inventories or /inventories.json
  def index
    # Build the Ransack query for filtering/searching
    @q = Inventory.where(site_id: @user.current_site_id).ransack(params[:q])

    @inventories = @q.result(distinct: true).includes(
      :asset_group,
      :sub_group,
      site_asset: [
        :site,
        :building,
        :floor,
        :asset_group,
        :sub_group
      ]
    ).order(created_at: :desc).page(params[:page]).per(params[:per_page] || 250)

    respond_to do |format|
      format.json { render 'index' }
    end
  end


  # GET /inventories/1 or /inventories/1.json
  def show
  end

  # GET /inventories/new
  def new
    @inventory = Inventory.new
  end

  # GET /inventories/1/edit
  def edit
  end

  # POST /inventories or /inventories.json
  def create
    @inventory = Inventory.new(inventory_params)

    respond_to do |format|
      if @inventory.save
        format.html { redirect_to @inventory, notice: "Inventory was successfully created." }
        format.json { render :show, status: :created, location: @inventory }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @inventory.errors, status: :unprocessable_entity }
      end
    end
  end

  def import
    file = params[:file]
    if file.nil?
      render json: { error: 'Please upload a file' }, status: :bad_request
      return
    end

    begin
      Inventory.import_from_excel(file)
      render json: { message: 'Data imported successfully' }, status: :ok
    rescue StandardError => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end

  def download_sample
    file_path = Rails.root.join('public', 'sample_files', 'import_inventories.xlsx')

    if File.exist?(file_path)
      send_file(
        file_path,
        filename: "import_inventories.xlsx",
        type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
      )
    else
      render json: { error: "Sample file not found" }, status: :not_found
    end
  end

  # PATCH/PUT /inventories/1 or /inventories/1.json
  def update
    respond_to do |format|
      if @inventory.update(inventory_params)
        format.html { redirect_to @inventory, notice: "Inventory was successfully updated." }
        format.json { render :show, status: :ok, location: @inventory }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @inventory.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /inventories/1 or /inventories/1.json
  def destroy
    @inventory.destroy
    respond_to do |format|
      format.html { redirect_to inventories_url, notice: "Inventory was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_inventory
    @inventory = Inventory.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def inventory_params
    params.require(:inventory).permit(:site_id, :name, :category,:inventory_type, :site_id, :criticality, :asset_group_id, :asset_sub_group_id, :asset_id, :code, :serial_number, :quantity, :min_stock_level, :min_order_level, :cgst_rate, :sgst_rate, :igst_rate, :active, :hsn_id, :expiry_date, :unit, :cost)
  end
end
