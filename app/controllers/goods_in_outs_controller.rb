class GoodsInOutsController < ApplicationController
  include UserExt
  layout 'basic'
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_goods_in_out, only: %i[ show edit update destroy ]

  # GET /goods_in_outs or /goods_in_outs.json
  def index
    base_query = GoodsInOut.includes(:visitor, :staff, :site, :goods_files, :qr_code_image).where(site_id: @user.current_site_id)
    @q = base_query.ransack(params[:q])
    @goods_in_outs = @q.result(distinct: true).order(created_at: :desc).paginate(page: params[:page], per_page: params[:per_page] || 1000)
  end

  # GET /goods_in_outs/1 or /goods_in_outs/1.json
  def show
  end

  def goods_qr_codes
    @goods_in_outs = GoodsInOut.where(site_id: @user.current_site_id)

    render pdf: 'goods_qr_codes',
      disposition: 'attachment',
      dpi: 72,
      template: 'goods_in_outs/qr_codes.html',
      formats: :pdf,
      encoding: 'utf8'
  end

  # GET /goods_in_outs/new
  def new
    @goods_in_out = GoodsInOut.new
  end

  # GET /goods_in_outs/1/edit
  def edit
  end

  # POST /goods_in_outs or /goods_in_outs.json
  def create
    @goods_in_out = GoodsInOut.new(goods_in_out_params.merge(site_id: @user.current_site_id))
    @goods_in_out.created_by_id = @user.id
    respond_to do |format|
      if @goods_in_out.save
        if params[:goods_files].present?
          params[:goods_files].each do |doc|
            Attachfile.create(image: doc, relation: "GoodsFile", relation_id: @goods_in_out.id, active: 1)
          end
        end
        format.html { redirect_to @goods_in_out, notice: "Goods in out was successfully created." }
        format.json { render :show, status: :created, location: @goods_in_out }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @goods_in_out.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /goods_in_outs/1 or /goods_in_outs/1.json
  def update
    respond_to do |format|
      if @goods_in_out.update(goods_in_out_params)
        if params[:goods_files].present?
          params[:goods_files].each do |doc|
            Attachfile.create(image: doc, relation: "GoodsFile", relation_id: @goods_in_out.id, active: 1)
          end
        end
        format.html { redirect_to @goods_in_out, notice: "Goods in out was successfully updated." }
        format.json { render :show, status: :ok, location: @goods_in_out }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @goods_in_out.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /goods_in_outs/1 or /goods_in_outs/1.json
  def destroy
    @goods_in_out.destroy
    respond_to do |format|
      format.html { redirect_to goods_in_outs_url, notice: "Goods in out was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def check_goods
    @goods_in_out = GoodsInOut.find(params[:id])
    if params[:check_in]
      @goods_in_out.update(goods_in_time: Time.current, ward_type: "IN")
    else
      @goods_in_out.update(goods_out_time: Time.current, ward_type: "OUT")
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_goods_in_out
    @goods_in_out = GoodsInOut.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def goods_in_out_params
    params.require(:goods_in_out).permit(:visitor_id, :no_of_goods, :description, :ward_type, :vehicle_no, :person_name, :goods_in_time, :goods_out_time, :staff_id, :created_by_id, :site_id, :item_type, :item_category, :mode_of_transport, :company_name, :department, :reporting_time, :returnable_type, :expected_date, goods_items_attributes: [:id, :item_name, :quantity, :unit, :description, :_destroy], goods_files: [])
  end
end
