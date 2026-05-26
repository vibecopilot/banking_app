class FloorsController < ApplicationController
  include UserExt
  layout 'basic'
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_floor, only: %i[ show edit update destroy ]

  # GET /floors or /floors.json
  def index
    #@floors = Floor.where(site_id: @user.current_site_id).ransack(params[:q]).result
    site_id = params[:site_id]
    @floors = Floor.where(site_id: site_id || @user.current_site_id).ransack(params[:q]).result

    if params[:mob].present?
      render json: {"floors": @floors}
    end
  end

  # GET /floors/1 or /floors/1.json
  def show
  end

  # GET /floors/new
  def new
    @floor = Floor.new
  end

  # GET /floors/1/edit
  def edit
  end

  def import
    @file = params[:file]
    @uploadds = Floor.import(@file, @user)
    respond_to do |format|
      format.html {
        redirect_to request.referrer + "#" , notice: "Successfully imported floors"
      }
      format.json { render json: @uploadds }
    end
  end

  # POST /floors or /floors.json
  def create
    @floor = Floor.new(floor_params)

    respond_to do |format|
      if @floor.save
        format.html { redirect_to "/floors", notice: "Floor was successfully created." }
        format.json { render :show, status: :created, location: @floor }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @floor.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /floors/1 or /floors/1.json
  def update
    respond_to do |format|
      if @floor.update(floor_params)
        format.html { redirect_to @floor, notice: "Floor was successfully updated." }
        format.json { render :show, status: :ok, location: @floor }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @floor.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /floors/1 or /floors/1.json
  def destroy
    @floor.destroy
    respond_to do |format|
      format.html { redirect_to floors_url, notice: "Floor was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_floor
      @floor = Floor.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def floor_params
      params.require(:floor).permit(:name, :building_id, :site_id)
    end
end
