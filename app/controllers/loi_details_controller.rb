class LoiDetailsController < ApplicationController
  include UserExt
  layout 'basic'
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_loi_detail, only: %i[ show edit update destroy ]


  # GET /loi_details or /loi_details.json
  def index
    @loi_details = LoiDetail.all.order(created_at: :DESC)
  end

  # GET /loi_details/1 or /loi_details/1.json
  def show
  end

  # GET /loi_details/new
  def new
    @loi_detail = LoiDetail.new
  end

  # GET /loi_details/1/edit
  def edit
  end

  # POST /loi_details or /loi_details.json
  def create
    #
    @loi_detail = LoiDetail.new(loi_detail_params)

    respond_to do |format|
      if @loi_detail.save
        if params[:loi_detail][:loi_items].present?
          params[:loi_detail][:loi_items].each do |item|
            @loi_item = LoiItem.new(item.permit(:item_id, :sac_code, :quantity, :standard_unit_id, :expected_date, :rate, :csgt_rate, :csgt_amt, :sgst_rate, :sgst_amt, :igst_rate, :igst_amt, :tcs_rate, :tcs_amt, :tax_amt, :amount, :total_amount))
            @loi_item.loi_detail_id = @loi_detail.id
            @loi_item.save
          end
        end
        if params[:attachfiles].present?
          params[:attachfiles].each do |doc|
            Attachfile.create(image: doc, relation: "LoiDetailDocument", relation_id: @loi_detail.id, active: 1)
          end
        end
        # if params[:loi_detail][:loi_items].present? && params[:loi_detail][:loi_items].is_a?(Array)
        #   params[:loi_detail][:loi_items].each do |item|
        #     next unless item.is_a?(ActionController::Parameters) || item.is_a?(Hash)
        #     @loi_item = LoiItem.new(item.permit(:item_id, :sac_code, :quantity, :standard_unit_id, :expected_date, :rate, :csgt_rate, :csgt_amt, :sgst_rate, :sgst_amt, :igst_rate, :igst_amt, :tcs_rate, :tcs_amt, :tax_amt, :amount, :total_amount))
        #     @loi_item.loi_detail_id = @loi_detail.id
        #     @loi_item.save
        #   end
        # end

        format.html { redirect_to @loi_detail, notice: "Loi detail was successfully created." }
        format.json { render :show, status: :created, location: @loi_detail }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @loi_detail.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /loi_details/1 or /loi_details/1.json
  def update
    respond_to do |format|
      if @loi_detail.update(loi_detail_params)
        if params[:attachfiles].present?
          params[:attachfiles].each do |doc|
            Attachfile.create(image: doc, relation: "LoiDetailDocument", relation_id: @loi_detail.id, active: 1)
          end
        end
        format.html { redirect_to @loi_detail, notice: "Loi detail was successfully updated." }
        format.json { render :show, status: :ok, location: @loi_detail }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @loi_detail.errors, status: :unprocessable_entity }
      end
    end
  end

  # ...existing code...

  # def create_approval_levels
  #   @loi_detail = LoiDetail.find(params[:id])
  #   # Parse JSON body if needed
  #   body_params = if request.body.present?
  #     JSON.parse(request.body.read).with_indifferent_access rescue {}
  #   else
  #     {}
  #   end
  #   level_id = (params[:level_id] || body_params[:level_id]).to_i
  #   approved_by_user_id = (params[:approved_by_user_id] || body_params[:approved_by_user_id]).to_i
  #   comment = params[:comment] || body_params[:comment]
  #   approval_comment = params[:approval_comment] || body_params[:approval_comment]
  #   Rails.logger.info "=== level_id: #{level_id}, approved_by_user_id: #{approved_by_user_id} ==="
  #   if level_id.zero? || approved_by_user_id.zero?
  #     render json: { error: "level_id and approved_by_user_id are required" }, status: :unprocessable_entity
  #     return
  #   end
  #   @loi_detail.create_approval_levels(approved_by_user_id, level_id, comment)
  #   render json: { message: "Approval Record Successfully!" }
  # end

  def create_approval_levels
    @loi_detail = LoiDetail.find(params[:id])
    level_id = params[:level_id].to_i
    approved_by_user_id = params[:approved_by_user_id].to_i
    comment = params[:comment].to_s
    approval_comment = params[:approval_comment].to_s

    Rails.logger.info "=== level_id: #{level_id}, approved_by_user_id: #{approved_by_user_id} ==="
    Rails.logger.info "=== approval_comment: #{approval_comment.inspect} ==="

    if level_id.zero? || approved_by_user_id.zero?
      render json: { error: "level_id and approved_by_user_id are required" }, status: :unprocessable_entity
      return
    end

    @loi_detail.create_approval_levels(
      approved_by_user_id,
      level_id,
      comment,
      approval_comment
    )

    render json: { message: "Approval Record Successfully!" }
  end


  # DELETE /loi_details/1 or /loi_details/1.json
  def destroy
    @loi_detail.destroy
    respond_to do |format|
      format.html { redirect_to loi_details_url, notice: "Loi detail was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_loi_detail
    @loi_detail = LoiDetail.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def loi_detail_params
    params.require(:loi_detail).permit(:loi_type, :pr_no, :reference, :loi_comments, :self_id, :loi_date, :created_by_id, :billing_address_id, :delivery_address_id, :transportation_amount, :retention, :tds, :qc, :payment_tenure, :advance_amount, :related_to, :terms, :is_approved, :site_id, :vendor_id)
  end
end
