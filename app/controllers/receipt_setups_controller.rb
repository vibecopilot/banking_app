class ReceiptSetupsController < ApplicationController
  
      include UserExt
    before_action :authenticate_user!, if: :check_user
    before_action :api_user
    before_action :set_user
  before_action :set_receipt_setup, only: %i[ show edit update destroy ]

  # GET /receipt_setups or /receipt_setups.json
  def index
    @receipt_setups = ReceiptSetup.all
  end

  # GET /receipt_setups/1 or /receipt_setups/1.json
  def show
  end

  # GET /receipt_setups/new
  def new
    @receipt_setup = ReceiptSetup.new
  end

  # GET /receipt_setups/1/edit
  def edit
  end

  # POST /receipt_setups or /receipt_setups.json
  def create
    @receipt_setup = ReceiptSetup.new(receipt_setup_params)
    @receipt_setup.created_by = @user.id
    @receipt_setup.site_id = @user.current_site_id

    respond_to do |format|
      if @receipt_setup.save
        format.html { redirect_to @receipt_setup, notice: "Receipt setup was successfully created." }
        format.json { render :show, status: :created, location: @receipt_setup }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @receipt_setup.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /receipt_setups/1 or /receipt_setups/1.json
  def update
    respond_to do |format|
      if @receipt_setup.update(receipt_setup_params)
        format.html { redirect_to @receipt_setup, notice: "Receipt setup was successfully updated." }
        format.json { render :show, status: :ok, location: @receipt_setup }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @receipt_setup.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /receipt_setups/1 or /receipt_setups/1.json
  def destroy
    @receipt_setup.destroy
    respond_to do |format|
      format.html { redirect_to receipt_setups_url, notice: "Receipt setup was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_receipt_setup
      @receipt_setup = ReceiptSetup.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def receipt_setup_params
      params.require(:receipt_setup).permit(:prefix, :next_number, :auto_generate, :receipt_number, :created_by, :site_id)
    end
end
