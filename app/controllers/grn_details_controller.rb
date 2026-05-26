class GrnDetailsController < ApplicationController
  before_action :set_grn_detail, only: %i[ show edit update destroy ]

  # GET /grn_details or /grn_details.json
  def index
    # Build the Ransack query for filtering/searching
    @q = GrnDetail.ransack(params[:q])
    per_page = (params[:per_page] || 250).to_i
    @grn_details = @q.result(distinct: true)
                     .includes(:inventory_details)
                     .order(created_at: :desc)
                     .page(params[:page])
                     .per(per_page)
    
    respond_to do |format|
      format.json { render 'index' }
    end
  end


  # GET /grn_details/1 or /grn_details/1.json
  def show
  end

  # GET /grn_details/new
  def new
    @grn_detail = GrnDetail.new
  end

  # GET /grn_details/1/edit
  def edit
  end

  # POST /grn_details or /grn_details.json
  def create
    @grn_detail = GrnDetail.new(grn_detail_params)

    # Generate unique GRN ID
    @grn_detail.grn_unique_id = generate_unique_grn_id

    respond_to do |format|
      if @grn_detail.save
        # Process inventory details
        inventory_details_params = parse_inventory_details

        if inventory_details_params.present?
          inventory_details_params.each do |inv_data|
            next if inv_data[:item_id].blank?

            # Prepare batches - handle both array and hash formats
            batches_value = if inv_data[:batches].present?
              if inv_data[:batches].is_a?(Array)
                inv_data[:batches].to_json
              elsif inv_data[:batches].is_a?(Hash)
                inv_data[:batches].values.to_json
              else
                inv_data[:batches].to_s
              end
            else
              nil
            end

            # Create inventory detail with all parameters
            inventory_detail = @grn_detail.inventory_details.create(
              item_id: inv_data[:item_id],
              expected_quantity: inv_data[:expected_quantity],
              received_quantity: inv_data[:received_quantity],
              approved_quantity: inv_data[:approved_quantity],
              rejected_quantity: inv_data[:rejected_quantity],
              rate: inv_data[:rate],
              csgt_rate: inv_data[:csgt_rate],
              csgt_amt: inv_data[:csgt_amt],
              sgst_rate: inv_data[:sgst_rate],
              sgst_amt: inv_data[:sgst_amt],
              igst_rate: inv_data[:igst_rate],
              igst_amt: inv_data[:igst_amt],
              tcs_rate: inv_data[:tcs_rate],
              tcs_amt: inv_data[:tcs_amt],
              tax_amt: inv_data[:tax_amt],
              inventory_amount: inv_data[:inventory_amount],
              total_amount: inv_data[:total_amount],
              inventory_type: inv_data[:inventory_type],
              criticality: inv_data[:criticality],
              batches: batches_value
            )

            # Log any errors for debugging
            unless inventory_detail.persisted?
              Rails.logger.error "Failed to save inventory detail: #{inventory_detail.errors.full_messages}"
              Rails.logger.error "Inventory data: #{inv_data.inspect}"
            else
              Rails.logger.info "Successfully saved inventory detail: #{inventory_detail.id} with data: #{inv_data.inspect}"
            end
          end
        end

        format.html { redirect_to @grn_detail, notice: "Grn detail was successfully created." }
        format.json { render :show, status: :created, location: @grn_detail }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @grn_detail.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /grn_details/1 or /grn_details/1.json
  def update
    respond_to do |format|
      if @grn_detail.update(grn_detail_params)
        # Update inventory details if provided
        if params[:inventory_details].present?
          # Optional: Clear existing inventory details if you want to replace all
          # @grn_detail.inventory_details.destroy_all

          params[:inventory_details].each do |inv|
            next if inv[:item_id].blank?

            # Find or create inventory detail
            inventory_detail = if inv[:id].present?
              @grn_detail.inventory_details.find_or_initialize_by(id: inv[:id])
            else
              @grn_detail.inventory_details.new
            end

            # Update attributes
            inventory_detail.assign_attributes(
              item_id: inv[:item_id],
              expected_quantity: inv[:expected_quantity],
              received_quantity: inv[:received_quantity],
              approved_quantity: inv[:approved_quantity],
              rejected_quantity: inv[:rejected_quantity],
              rate: inv[:rate],
              csgt_rate: inv[:csgt_rate],
              csgt_amt: inv[:csgt_amt],
              sgst_rate: inv[:sgst_rate],
              sgst_amt: inv[:sgst_amt],
              igst_rate: inv[:igst_rate],
              igst_amt: inv[:igst_amt],
              tcs_rate: inv[:tcs_rate],
              tcs_amt: inv[:tcs_amt],
              tax_amt: inv[:tax_amt],
              inventory_amount: inv[:inventory_amount],
              total_amount: inv[:total_amount],
              inventory_type: inv[:inventory_type],
              criticality: inv[:criticality],
              batches: inv[:batches]&.to_json
            )

            inventory_detail.save
          end
        end

        format.html { redirect_to @grn_detail, notice: "Grn detail was successfully updated." }
        format.json { render :show, status: :ok, location: @grn_detail }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @grn_detail.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /grn_details/1 or /grn_details/1.json
  def destroy
    @grn_detail.destroy
    respond_to do |format|
      format.html { redirect_to grn_details_url, notice: "Grn detail was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_grn_detail
    @grn_detail = GrnDetail.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def grn_detail_params
    params.require(:grn_detail).permit(:loi_detail_id, :vendor_id, :created_by_id, :payment_mode, :invoice_number, :related_to, :invoice_amount, :invoice_date, :posting_date, :other_expenses, :loading_expenses, :adjustment_amount, :notes)
  end

  # Generate unique GRN ID like GR12A4
  def generate_unique_grn_id
    loop do
      # Generate random alphanumeric ID: GR + 2 digits + 1 letter + 1 digit
      random_digits_1 = rand(10..99)
      random_letter = ('A'..'Z').to_a.sample
      random_digit_2 = rand(0..9)
      grn_id = "GR#{random_digits_1}#{random_letter}#{random_digit_2}"

      # Check if this ID already exists
      break grn_id unless GrnDetail.exists?(grn_unique_id: grn_id)
    end
  end

  # Parse inventory details from params - handles both JSON and FormData formats
  def parse_inventory_details
    return [] unless params[:inventory_details].present?

    inventory_details = []

    # Handle JSON format (when sent as application/json)
    if params[:inventory_details].is_a?(Array)
      Rails.logger.info "Processing inventory_details as JSON array"
      return params[:inventory_details]
    end

    # Handle FormData format (when sent as multipart/form-data)
    # FormData sends params like: inventory_details[0][field], inventory_details[1][field], etc.
    if params[:inventory_details].is_a?(Hash) || params[:inventory_details].is_a?(ActionController::Parameters)
      Rails.logger.info "Processing inventory_details as FormData hash"

      # Group all parameters by index
      grouped_params = {}

      params[:inventory_details].each do |key, value|
        # Extract index from key like "0", "1", etc.
        if key.to_s.match?(/^\d+$/)
          grouped_params[key.to_i] = value
        end
      end

      # Convert grouped params to array
      grouped_params.keys.sort.each do |index|
        item_data = grouped_params[index]

        # Handle batches specially - they might come as nested hash
        batches = if item_data[:batches].present?
          if item_data[:batches].is_a?(Hash)
            item_data[:batches].values.reject(&:blank?)
          elsif item_data[:batches].is_a?(Array)
            item_data[:batches].reject(&:blank?)
          else
            [item_data[:batches]].reject(&:blank?)
          end
        else
          []
        end

        inventory_details << {
          item_id: item_data[:item_id],
          expected_quantity: item_data[:expected_quantity],
          received_quantity: item_data[:received_quantity],
          approved_quantity: item_data[:approved_quantity],
          rejected_quantity: item_data[:rejected_quantity],
          rate: item_data[:rate],
          csgt_rate: item_data[:csgt_rate],
          csgt_amt: item_data[:csgt_amt],
          sgst_rate: item_data[:sgst_rate],
          sgst_amt: item_data[:sgst_amt],
          igst_rate: item_data[:igst_rate],
          igst_amt: item_data[:igst_amt],
          tcs_rate: item_data[:tcs_rate],
          tcs_amt: item_data[:tcs_amt],
          tax_amt: item_data[:tax_amt],
          inventory_amount: item_data[:inventory_amount],
          total_amount: item_data[:total_amount],
          inventory_type: item_data[:inventory_type],
          criticality: item_data[:criticality],
          batches: batches
        }
      end

      Rails.logger.info "Parsed #{inventory_details.count} inventory items from FormData"
      return inventory_details
    end

    Rails.logger.warn "Unknown inventory_details format: #{params[:inventory_details].class}"
    []
  end
end
