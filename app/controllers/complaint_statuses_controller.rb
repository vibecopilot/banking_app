class ComplaintStatusesController < ApplicationController

  # GET /complaint_statuses or /statuses.json
  def index
    statuses = ComplaintStatus.all.order(position: :asc, created_at: :desc)
    render json: statuses.as_json(only: [:id, :society_id, :name, :color_code, :fixed_state, :active, :created_at, :updated_at, :position, :of_phase, :of_atype])
  end

  # GET /complaint_statuses/1 or /statuses/1.json
  def show
    status = ComplaintStatus.find(params[:id])
    render json: status.as_json(only: [:id, :society_id, :name, :color_code, :fixed_state, :active, :created_at, :updated_at, :position, :of_phase, :of_atype])
  end

  # POST /complaint_statuses or /statuses.json
  def create
    status = ComplaintStatus.new(complaint_status_params)
    if status.save
      render json: status.as_json(only: [:id, :society_id, :name, :color_code, :fixed_state, :active, :created_at, :updated_at, :position, :of_phase, :of_atype])
    else
      render json: status.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /complaint_statuses/1 or /statuses/1.json
  def update
    status = ComplaintStatus.find(params[:id])
    if status.update(complaint_status_params)
      render json: status.as_json(only: [:id, :society_id, :name, :color_code, :fixed_state, :active, :created_at, :updated_at, :position, :of_phase, :of_atype])
    else
      render json: status.errors, status: :unprocessable_entity
    end
  end

  # DELETE /complaint_statuses/1 or /statuses/1.json
  def destroy
    status = ComplaintStatus.find(params[:id])
    status.destroy
    render json: { message: "Status was successfully deleted" }
  end

  private

  def complaint_status_params
    params.require(:complaint_status).permit(:name, :society_id, :color_code, :fixed_state, :active, :position, :of_phase, :of_atype)
  end
end
