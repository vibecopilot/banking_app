class GenericInfosController < ApplicationController
  include UserExt
  layout 'basic'
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_generic_info, only: %i[ show edit update destroy ]

  # GET /generic_infos or /generic_infos.json
  def index
    @q = GenericInfo.ransack(params[:q])
    base_scope = @q.result.where(site_id: @user.current_site_id).includes(:generic_sub_infos ,generic_sub_infos: :generic_sub_files).order(created_at: :desc)
    @generic_infos = base_scope.page(params[:page]).per(params[:per_page] || 500)
  end

  def get_site_owner
    @generic_infos = GenericInfo.ransack(params[:q]).result
    render format: :json
  end

  

  def get_sub_generic_info
    @generic_sub_info = GenericSubInfo.where(generic_info_id:params[:group_id])
    respond_to do |format|
      format.json do
        render json: { subgroups: @generic_sub_info.as_json }
      end
    end
  end
  # GET /generic_infos/1 or /generic_infos/1.json
  def show
  end

  # GET /generic_infos/new
  def new
    @generic_info = GenericInfo.new
  end

  # GET /generic_infos/1/edit
  def edit
  end

  # POST /generic_infos or /generic_infos.json
  def create
    if params[:generic_info][:info_type] == "SiteOwner"
      generic_info = GenericInfo.find_by(site_id: @user.current_site_id, info_type: "SiteOwner")
      if generic_info.present?
        return render json: { message: "SiteOwner already exists for this site" }, status: :unprocessable_entity
      end
    end

    @generic_info = GenericInfo.new(generic_info_params)

    respond_to do |format|
      if @generic_info.save
        if params[:generic_info][:generic_sub_infos].present?
          params[:generic_info][:generic_sub_infos].each do |sub_info|
            sub_info_permitted = sub_info.permit(:name)
            @generic_info.generic_sub_infos.create(sub_info_permitted)
          end
        end
        format.html { redirect_to @generic_info, notice: "Generic info was successfully created." }
        format.json { render :show, status: :created, location: @generic_info }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @generic_info.errors, status: :unprocessable_entity }
      end
    end
  end


  # PATCH/PUT /generic_infos/1 or /generic_infos/1.json
  def update
    respond_to do |format|
      if @generic_info.update(generic_info_params)
        format.html { redirect_to @generic_info, notice: "Generic info was successfully updated." }
        format.json { render :show, status: :ok, location: @generic_info }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @generic_info.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /generic_infos/1 or /generic_infos/1.json
  def destroy
    @generic_info.destroy
    respond_to do |format|
      format.html { redirect_to generic_infos_url, notice: "Generic info was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_generic_info
      @generic_info = GenericInfo.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def generic_info_params
      params.require(:generic_info).permit(:name, :company_id, :site_id, :info_type, :time,generic_sub_infos_attributes: [:name])
    end
end
