class GenericSubInfosController < ApplicationController
  include UserExt
  layout 'basic'
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_generic_info, only: [:index]
  before_action :set_generic_sub_info, only: [:show, :edit, :update, :destroy]

  # GET /generic_sub_infos or /generic_sub_infos.json
  def index
    @generic_sub_infos =
      if params[:generic_info_id]
        GenericSubInfo.where(generic_info_id: params[:generic_info_id]).includes(:generic_sub_files, :contact_books, :generic_info).order(created_at: :desc)
    else
      GenericSubInfo.ransack(params[:q]).result.includes(:generic_sub_files, :contact_books, :generic_info).order(created_at: :desc)
    end
  end

def get_sub_categories
  @generic_infos = GenericInfo.where(site_id: @user.current_site_id, info_type: "RestaurantCategory").ransack(params[:q]).result
  generic_info_ids = @generic_infos.pluck(:id)
  @sub_generic_infos = GenericSubInfo.where(generic_info_id: generic_info_ids)

  sub_categories_json = @sub_generic_infos.map do |generic_sub_info|
    {
      id: generic_sub_info.id,
      generic_info_id: generic_sub_info.generic_info_id,
      name: generic_sub_info.name,
      created_at: generic_sub_info.created_at,
      updated_at: generic_sub_info.updated_at,
      generic_info_name: generic_sub_info.generic_info&.name,
      generic_info_type: generic_sub_info.generic_info&.info_type,
      generic_sub_files: Attachfile.where("relation = 'GenericSubFile' and relation_id = ?", generic_sub_info.id).map do |doc|
        {
          id: doc.id,
          relation: doc.relation,
          relation_id: doc.relation_id,
          document: doc.document_url
        }
      end,
      url: generic_info_generic_sub_info_url(generic_sub_info.generic_info, generic_sub_info, format: :json)
    }
  end

  render json: { success: true, sub_categories: sub_categories_json }, status: :ok
end




  # generic_cab_type = GenericInfo.find_by(site_id: site_id, info_type: 'cab_type')
  # if generic_cab_type
  #   generic_sub_cab_type = generic_cab_type.generic_sub_infos.try(:name)
  # GET /generic_sub_infos/1 or /generic_sub_infos/1.json
  def show
  end

  # GET /generic_sub_infos/new
  def new
    @generic_sub_info = GenericSubInfo.new
  end

  # GET /generic_sub_infos/1/edit
  def edit
  end

  # POST /generic_sub_infos or /generic_sub_infos.json
  def create
    @generic_sub_info = GenericSubInfo.new(generic_sub_info_params)

    respond_to do |format|
      if @generic_sub_info.save
        if params[:generic_sub_info][:generic_sub_files].present?
          Array(params[:generic_sub_info][:generic_sub_files]).each do |file|
            Attachfile.create(image: file, relation: "GenericSubFile", relation_id: @generic_sub_info.id, active: 1)
          end
        end
        format.html { redirect_to @generic_sub_info, notice: "Generic sub info was successfully created." }
        format.json { render :show, status: :created, location: @generic_sub_info }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @generic_sub_info.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /generic_sub_infos/1 or /generic_sub_infos/1.json
  def update
    respond_to do |format|
      if @generic_sub_info.update(generic_sub_info_params)
        if params[:generic_sub_info][:generic_sub_files].present?
          Array(params[:generic_sub_info][:generic_sub_files]).each do |file|
            Attachfile.create(image: file, relation: "GenericSubFile", relation_id: @generic_sub_info.id, active: 1)
          end
        end
        format.html { redirect_to @generic_sub_info, notice: "Generic sub info was successfully updated." }
        format.json { render :show, status: :ok, location: @generic_sub_info }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @generic_sub_info.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /generic_sub_infos/1 or /generic_sub_infos/1.json
  def destroy
    @generic_sub_info.destroy
    respond_to do |format|
      format.html { redirect_to generic_sub_infos_url, notice: "Generic sub info was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_generic_sub_info
      @generic_sub_info = GenericSubInfo.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def generic_sub_info_params
      params.require(:generic_sub_info).permit(:generic_info_id, :name, generic_sub_files: [])
    end

    def set_generic_info
      @generic_info = GenericInfo.find(params[:generic_info_id]) if params[:generic_info_id]
    end

end
