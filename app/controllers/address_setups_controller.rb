class AddressSetupsController < ApplicationController
    include UserExt
  layout 'basic'
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_address_setup, only: %i[ show edit update destroy ]

  # GET /address_setups or /address_setups.json
  def index
    @address_setups = AddressSetup.where(site_id: @user.current_site_id)
  end

  # GET /address_setups/1 or /address_setups/1.json
  def show
  end

  # GET /address_setups/new
  def new
    @address_setup = AddressSetup.new
  end

  # GET /address_setups/1/edit
  def edit
  end

  # POST /address_setups or /address_setups.json
  def create
    @address_setup = AddressSetup.new(address_setup_params)
    @address_setup.site_id = @user.current_site_id
    respond_to do |format|
      if @address_setup.save
        if params[:attachments].present? 
          params[:attachments].each do |doc|
            Attachfile.create(image: doc, relation: "AddressSetup", relation_id: @address_setup.id, active: 1)
          end
        end
        format.html { redirect_to @address_setup, notice: "Address setup was successfully created." }
        format.json { render :show, status: :created, location: @address_setup }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @address_setup.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /address_setups/1 or /address_setups/1.json
  def update
    respond_to do |format|
      if @address_setup.update(address_setup_params)
        format.html { redirect_to @address_setup, notice: "Address setup was successfully updated." }
        format.json { render :show, status: :ok, location: @address_setup }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @address_setup.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /address_setups/1 or /address_setups/1.json
  def destroy
    @address_setup.destroy
    respond_to do |format|
      format.html { redirect_to address_setups_url, notice: "Address setup was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_address_setup
      @address_setup = AddressSetup.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def address_setup_params
      params.require(:address_setup).permit(
        :title, 
        :address, 
        :building_id, 
        :state, 
        :phone_number, 
        :fax_number, 
        :email_address, 
        :registration_no, 
        :pan_number, 
        :cheque_in_favour_of, 
        :gst_number, 
        :account_number, 
        :account_type, 
        :ifsc_code, 
        :account_name, 
        :bank_branch_name
      )
    end
end
