class FitoutRequestController < ApplicationController

  def index
    # Initialize ransack search with params[:q]
    @q = FitoutRequest.ransack(params[:q])

    # Run the query and order
    @fitout_requests = @q.result(distinct: true)
    .order(created_at: :desc)
    .paginate(page: params[:page], per_page: params[:per_page] || 100)
    
    # Process each fitout request to handle fallbacks for building and floor
    processed_fitout_requests = @fitout_requests.map do |fr|
      json = fr.as_json(
        include: {
          user: { only: [:id, :firstname, :lastname, :email] },
          supplier: { only: [:id, :vendor_name, :company_name, :email, :mobile] },
          fitout_request_categories: {
            only: [:id, :status, :fitout_request_id, :category_type_id, :attachfile_id],
            include: {
              attachfile: { only: [:id, :relation, :relation_id], methods: [:document_url] },
              category_type: { only: [:id, :name] }
            },
            methods: [:category_name]
          },
          unit: { only: [:id, :name] },
        }
      )
      
      # Use effective building and floor (with fallbacks)
      effective_building = fr.effective_building
      effective_floor = fr.effective_floor
      
      if effective_building
        json["building"] = { id: effective_building.id, name: effective_building.name }
      else
        json["building"] = nil
      end
      
      if effective_floor
        json["floor"] = { id: effective_floor.id, name: effective_floor.name }
      else
        json["floor"] = nil
      end
      
      json
    end
    
    render json: {
      total_pages: @fitout_requests.total_pages,
      total_count: @fitout_requests.total_entries,
      current_page: @fitout_requests.current_page,
      fitout_requests: processed_fitout_requests
    }
  end


  def show
    @fitout_request = FitoutRequest.find(params[:id])

    # Create the base JSON response
    json = @fitout_request.as_json(
      include: {
        user: { only: [:id, :firstname, :lastname, :email] },
        supplier: { only: [:id, :vendor_name, :company_name, :email, :mobile] },
        fitout_request_categories: {
          only: [:id, :status, :fitout_request_id, :category_type_id, :attachfile_id],
          include: {
            attachfile: { only: [:id, :relation, :relation_id], methods: [:document_url] },
            category_type: { only: [:id, :name] }
          },
          methods: [:category_name]
        },
        unit: { only: [:id, :name] },

      }
    )
    
    # Use effective building and floor (with fallbacks)
    effective_building = @fitout_request.effective_building
    effective_floor = @fitout_request.effective_floor
    
    if effective_building
      json["building"] = { id: effective_building.id, name: effective_building.name }
    else
      json["building"] = nil
    end
    
    if effective_floor
      json["floor"] = { id: effective_floor.id, name: effective_floor.name }
    else
      json["floor"] = nil
    end
    
    render json: json
  end

  def new
    @fitout_request = FitoutRequest.new
  end

  def create
    @fitout_request = FitoutRequest.new(fitout_request_params)

    if @fitout_request.save
      if params[:fitout_request][:category_images].present?
        images = params[:fitout_request][:category_images].is_a?(Array) ? params[:fitout_request][:category_images] : [params[:fitout_request][:category_images]]
        category_types = params[:fitout_request][:category_types] || []

        images.each_with_index do |doc, index|
          category_type_value = category_types[index] || category_types.first
          attachfile = Attachfile.create(
            image: doc,
            category_type: category_type_value,
            relation: "FitoutRequest",
            relation_id: @fitout_request.id,
            active: 1
          )
          FitoutRequestCategory.create(
            fitout_request_id: @fitout_request.id,
            category_type_id: category_type_value,
            attachfile_id: attachfile.id
          )
        end
      end

      # Send email notification
      begin
        FitoutRequestMailer.fitout_mail_request(@fitout_request).deliver_now
      rescue => e
        Rails.logger.error "Failed to send fitout request email: #{e.message}"
      end

      redirect_to @fitout_request, notice: 'Fitout Request was successfully created.'
    else
      render json: { status: 422, message: "unprocessible entity", errors: @fitout_request.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def edit
    @fitout_request = FitoutRequest.find(params[:id])
  end

  def update
    @fitout_request = FitoutRequest.find(params[:id])

    if params[:category_id].present? && params[:status].present?
      category = FitoutRequestCategory.find_by(
        fitout_request_id: @fitout_request.id,
        id: params[:category_id]
      )

      if category
        category.update(
          status: params[:status],
          updated_by_id: current_user&.id
        )

        # Optional comment support
        # category.comments.create(body: params[:comments], user_id: current_user.id) if params[:comments].present?

        render json: {
          success: true,
          message: "Category status updated successfully",
          category: category.as_json(include: { category_type: { only: [:id, :name] } })
        } and return
      else
        render json: { success: false, message: "Category not found" }, status: :not_found and return
      end
    end

    # Extract category_type_id before updating fitout_request
    category_type_id = params[:fitout_request][:category_type_id] || params[:category_type_id]

    if @fitout_request.update(fitout_request_params)

      if params[:fitout_request][:category_images].present?
        images = Array(params[:fitout_request][:category_images])

        images.each_with_index do |doc, index|
          attachfile = Attachfile.create(
            image: doc,
            relation: "FitoutRequest",
            relation_id: @fitout_request.id,
            active: 1
          )

          FitoutRequestCategory.create(
            fitout_request_id: @fitout_request.id,
            category_type_id: category_type_id,
            attachfile_id: attachfile.id
          )
        end
      end

      render json: {
        success: true,
        message: "Fitout Request updated successfully",
        fitout_request: @fitout_request
      }
    else
      render json: {
        success: false,
        errors: @fitout_request.errors.full_messages
      }, status: :unprocessable_entity
    end
  end
  # ...existing code...


  def destroy
    @fitout_request = FitoutRequest.find(params[:id])
    @fitout_request.destroy

    respond_to do |format|
      format.html { redirect_to fitout_request_path, notice: 'Fitout Request was successfully deleted.' }
      format.json { render json: { success: true }, status: :ok }
    end
  end


  def update_category_status
    @fitout_request = FitoutRequest.find(params[:id])
    category = FitoutRequestCategory.find_by(
      fitout_request_id: @fitout_request.id,
      id: params[:category_id]
    )

    if category && category.update(status: params[:status], updated_by_id: current_user&.id)
      render json: {
        success: true,
        message: "Category status updated successfully",
        category: category.as_json(include: { category_type: { only: [:id, :name] } })
      }
    else
      render json: { success: false, message: "Failed to update category status" }, status: 422
    end
  end

  def send_document_request
    @fitout_request = FitoutRequest.find(params[:id])
    
    begin
      @fitout_request.send_document_request_email
      render json: {
        success: true,
        message: "Document request email sent successfully to #{@fitout_request.user&.email}"
      }
    rescue => e
      render json: {
        success: false,
        message: "Failed to send email: #{e.message}"
      }, status: 422
    end
  end

  private

  def fitout_request_params
    params.require(:fitout_request).permit(
      :description,
      :status,
      :status_updated_by,
      :building_id,
      :floor_id,
      :unit_id,
      :user_id,
      :selected_date,
      :supplier_id,
      category_type:[]
    )
  end
end
