class BannersController < ApplicationController
    include UserExt
  layout 'basic'
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_banner, only: %i[ show edit update destroy ]

  # GET /banners or /banners.json
  def index
    @banners = Banner.where(site_id:@user.selected_site_id).ransack(params[:q]).result
  end

  # GET /banners/1 or /banners/1.json
  def show
  end

  # GET /banners/new
  def new
    @banner = Banner.new
  end

  # GET /banners/1/edit
  def edit
  end

  # POST /banners or /banners.json
  def create
    @banner = Banner.new(banner_params)
    respond_to do |format|
      if @banner.save
        if params[:attachments].present?
          params[:attachments].each do |doc|
            Attachfile.create(image: doc, relation: "Banner", relation_id: @banner.id, active: 1)
          end
        end
        format.html { redirect_to @banner, notice: "Banner was successfully created." }
        format.json { render :show, status: :created, location: @banner }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @banner.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /banners/1 or /banners/1.json
  def update
    respond_to do |format|
      if @banner.update(banner_params)
        format.html { redirect_to @banner, notice: "Banner was successfully updated." }
        format.json { render :show, status: :ok, location: @banner }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @banner.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /banners/1 or /banners/1.json
  def destroy
    @banner.destroy
    respond_to do |format|
      format.html { redirect_to banners_url, notice: "Banner was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_banner
      @banner = Banner.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def banner_params
      params.require(:banner).permit(:title, :description, :site_id)
    end
end
