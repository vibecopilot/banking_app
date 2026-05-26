class PermitExtensionsController < ApplicationController
  include UserExt
  layout 'basic'
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_permit_extension, only: %i[ show edit update destroy ]

  # GET /permit_extensions or /permit_extensions.json
  def index
    @permit_extensions = PermitExtension.where(site_id:@user.current_site_id).ransack(params[:q]).result
  end

  # GET /permit_extensions/1 or /permit_extensions/1.json
  def show
  end

  # GET /permit_extensions/new
  def new
    @permit_extension = PermitExtension.new
  end

  # GET /permit_extensions/1/edit
  def edit
  end

  # POST /permit_extensions or /permit_extensions.json
  def create
    @permit_extension = PermitExtension.new(permit_extension_params)

    respond_to do |format|
      if @permit_extension.save
        format.html { redirect_to @permit_extension, notice: "Permit extension was successfully created." }
        format.json { render :show, status: :created, location: @permit_extension }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @permit_extension.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /permit_extensions/1 or /permit_extensions/1.json
  def update
    respond_to do |format|
      if @permit_extension.update(permit_extension_params)
        format.html { redirect_to @permit_extension, notice: "Permit extension was successfully updated." }
        format.json { render :show, status: :ok, location: @permit_extension }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @permit_extension.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /permit_extensions/1 or /permit_extensions/1.json
  def destroy
    @permit_extension.destroy
    respond_to do |format|
      format.html { redirect_to permit_extensions_url, notice: "Permit extension was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_permit_extension
      @permit_extension = PermitExtension.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def permit_extension_params
      params.require(:permit_extension).permit(:permit_id, :site_id, :reason, :ext_date, :ext_time, assign_to_ids:[])
    end
end
