class ColorCodesController < ApplicationController
  before_action :set_color_code, only: %i[ show edit update destroy ]

  # GET /color_codes or /color_codes.json
  def index
    @color_codes = ColorCode.all
  end

  # GET /color_codes/1 or /color_codes/1.json
  def show
  end

  # GET /color_codes/new
  def new
    @color_code = ColorCode.new
  end

  # GET /color_codes/1/edit
  def edit
  end

  # POST /color_codes or /color_codes.json
  def create
    @color_code = ColorCode.new(color_code_params)

    respond_to do |format|
      if @color_code.save
        format.html { redirect_to @color_code, notice: "Color code was successfully created." }
        format.json { render :show, status: :created, location: @color_code }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @color_code.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /color_codes/1 or /color_codes/1.json
  def update
    respond_to do |format|
      if @color_code.update(color_code_params)
        format.html { redirect_to @color_code, notice: "Color code was successfully updated." }
        format.json { render :show, status: :ok, location: @color_code }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @color_code.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /color_codes/1 or /color_codes/1.json
  def destroy
    @color_code.destroy
    respond_to do |format|
      format.html { redirect_to color_codes_url, notice: "Color code was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_color_code
      @color_code = ColorCode.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def color_code_params
      params.require(:color_code).permit(:code)
    end
end
