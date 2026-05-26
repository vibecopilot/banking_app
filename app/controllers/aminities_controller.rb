class AminitiesController < ApplicationController
  before_action :set_aminity, only: %i[ show edit update destroy ]

  # GET /aminities or /aminities.json
  def index
    @aminities = Aminity.all
  end

  # GET /aminities/1 or /aminities/1.json
  def show
  end

  # GET /aminities/new
  def new
    @aminity = Aminity.new
  end

  # GET /aminities/1/edit
  def edit
  end

  # POST /aminities or /aminities.json
  def create
    @aminity = Aminity.new(aminity_params)

    respond_to do |format|
      if @aminity.save
        format.html { redirect_to @aminity, notice: "Aminity was successfully created." }
        format.json { render :show, status: :created, location: @aminity }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @aminity.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /aminities/1 or /aminities/1.json
  def update
    respond_to do |format|
      if @aminity.update(aminity_params)
        format.html { redirect_to @aminity, notice: "Aminity was successfully updated." }
        format.json { render :show, status: :ok, location: @aminity }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @aminity.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /aminities/1 or /aminities/1.json
  def destroy
    @aminity.destroy
    respond_to do |format|
      format.html { redirect_to aminities_url, notice: "Aminity was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_aminity
      @aminity = Aminity.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def aminity_params
      params.require(:aminity).permit(:name, :site_id, :cost, :cost)
    end
end
