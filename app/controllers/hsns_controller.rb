class HsnsController < ApplicationController
  before_action :set_hsn, only: %i[ show edit update destroy ]

  # GET /hsns or /hsns.json
  def index
    @q = Hsn.ransack(params[:q])
    @hsns = @q.result(distinct: true).order(created_at: :desc).page(params[:page]).per(params[:per_page] || 100)
    respond_to do |format|
      format.json { render 'index' }
    end
  end


  # GET /hsns/1 or /hsns/1.json
  def show
  end

  # GET /hsns/new
  def new
    @hsn = Hsn.new
  end

  # GET /hsns/1/edit
  def edit
  end

  # POST /hsns or /hsns.json
  def create
    @hsn = Hsn.new(hsn_params)

    respond_to do |format|
      if @hsn.save
        format.html { redirect_to @hsn, notice: "Hsn was successfully created." }
        format.json { render :show, status: :created, location: @hsn }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @hsn.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /hsns/1 or /hsns/1.json
  def update
    respond_to do |format|
      if @hsn.update(hsn_params)
        format.html { redirect_to @hsn, notice: "Hsn was successfully updated." }
        format.json { render :show, status: :ok, location: @hsn }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @hsn.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /hsns/1 or /hsns/1.json
  def destroy
    @hsn.destroy
    respond_to do |format|
      format.html { redirect_to hsns_url, notice: "Hsn was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_hsn
    @hsn = Hsn.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def hsn_params
    params.require(:hsn).permit(:category, :code, :sgst_rate, :cgst_rate, :igst_rate, :active, :created_by, :updated_by, :company_id, :hsn_type)
  end
end
