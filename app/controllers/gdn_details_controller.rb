class GdnDetailsController < ApplicationController
  before_action :set_gdn_detail, only: %i[ show edit update destroy ]

  # GET /gdn_details or /gdn_details.json
  def index
    per_page = (params[:per_page] || 250).to_i
    @gdn_details = GdnDetail.includes(:gdn_inventory_details)
                             .order(created_at: :desc)
                             .page(params[:page])
                             .per(per_page)
    
    respond_to do |format|
      format.html
      format.json
    end
  end

  # GET /gdn_details/1 or /gdn_details/1.json
  def show
  end

  # GET /gdn_details/new
  def new
    @gdn_detail = GdnDetail.new
  end

  # GET /gdn_details/1/edit
  def edit
  end

  # POST /gdn_details or /gdn_details.json
  def create
    @gdn_detail = GdnDetail.new(gdn_detail_params.except(:gdn_inventory_details))

    respond_to do |format|
      if @gdn_detail.save
        # Process GDN inventory details
        if params[:gdn_detail][:gdn_inventory_details].present?
          params[:gdn_detail][:gdn_inventory_details].each do |inventory|
            # Create GDN inventory detail
            gdn_inventory_detail = @gdn_detail.gdn_inventory_details.build(
              inventory: inventory[:inventory],
              current_stock: inventory[:current_stock],
              quantity: inventory[:quantity],
              comments: inventory[:comments],
              purpose_id: inventory[:purpose_id],
              handover_to_id: inventory[:handover_to_id],
              consuming_in_id: inventory[:consuming_in_id],
              service_id: inventory[:service_id].presence,
              asset_id: inventory[:asset_id].presence
            )
            
            # Save and log results
            if gdn_inventory_detail.save
              Rails.logger.info "Successfully saved GDN inventory detail: #{gdn_inventory_detail.id}"
            else
              Rails.logger.error "Failed to save GDN inventory detail: #{gdn_inventory_detail.errors.full_messages.join(', ')}"
              Rails.logger.error "Inventory data: #{inventory.inspect}"
            end
          end
        end
        
        # Reload to get saved inventory details
        @gdn_detail.reload
        
        format.html { redirect_to @gdn_detail, notice: "Gdn detail was successfully created." }
        format.json { render :show, status: :created, location: @gdn_detail }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @gdn_detail.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /gdn_details/1 or /gdn_details/1.json
  def update
    respond_to do |format|
      if @gdn_detail.update(gdn_detail_params.except(:gdn_inventory_details))
        
        # Update inventory details if provided
        if params[:gdn_detail][:gdn_inventory_details].present?
          params[:gdn_detail][:gdn_inventory_details].each do |inventory|
            # Find or create inventory detail
            gdn_inventory_detail = if inventory[:id].present?
              @gdn_detail.gdn_inventory_details.find_or_initialize_by(id: inventory[:id])
            else
              @gdn_detail.gdn_inventory_details.build
            end
            
            # Update attributes
            gdn_inventory_detail.assign_attributes(
              inventory: inventory[:inventory],
              current_stock: inventory[:current_stock],
              quantity: inventory[:quantity],
              comments: inventory[:comments],
              purpose_id: inventory[:purpose_id],
              handover_to_id: inventory[:handover_to_id],
              consuming_in_id: inventory[:consuming_in_id],
              service_id: inventory[:service_id].presence,
              asset_id: inventory[:asset_id].presence
            )
            
            gdn_inventory_detail.save
          end
        end
        
        @gdn_detail.reload
        
        format.html { redirect_to @gdn_detail, notice: "Gdn detail was successfully updated." }
        format.json { render :show, status: :ok, location: @gdn_detail }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @gdn_detail.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /gdn_details/1 or /gdn_details/1.json
  def destroy
    @gdn_detail.destroy
    respond_to do |format|
      format.html { redirect_to gdn_details_url, notice: "Gdn detail was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_gdn_detail
      @gdn_detail = GdnDetail.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def gdn_detail_params
      params.require(:gdn_detail).permit(
        :gdn_date, 
        :description, 
        :status, 
        :created_by_id,
        gdn_inventory_details: [
          :inventory, 
          :current_stock, 
          :quantity, 
          :comments, 
          :gdn_id, 
          :purpose_id, 
          :handover_to_id, 
          :consuming_in_id, 
          :service_id, 
          :asset_id
        ]
      )
    end
end
