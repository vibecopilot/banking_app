class FitoutStatusesController < ApplicationController
  before_action :set_fitout_status, only: %i[show edit update destroy]
  protect_from_forgery with: :null_session, if: -> { request.format.json? }

  def index
    @fitout_statuses = FitoutStatus.order(created_at: :desc)
    render json: @fitout_statuses
  end

  def show
  	@fitout_statuses = FitoutStatus.find(params[:id])
    render json: @fitout_statuses
  end

  def new
    @fitout_status = FitoutStatus.new
  end

 def create
  @fitout_status = FitoutStatus.new(fitout_status_params.merge(is_active: 1))
  @fitout_status.name = params[:fitout_status][:name].downcase.titleize.squeeze(" ")
  if params[:fitout_status][:of_phase].blank?
    params[:fitout_status][:of_phase] = "pms"
  end

  site_id = @user&.current_site_id || 65

  #@fitout_statuses = FitoutStatus.active.where(society_id: @user.current_site_id, of_phase: params[:fitout_status][:of_phase])
  # @fitout_statuses = FitoutStatus.where(active: 1, society_id: @user.current_site_id, of_phase: params[:fitout_status][:of_phase])
  @fitout_statuses = FitoutStatus.where(is_active: 1, society_id: site_id, of_phase: params[:fitout_status][:of_phase])
  @fitout_status_name = @fitout_statuses.pluck(:name)
  @fitout_status_position = @fitout_statuses.pluck(:position)

  name_exist = @fitout_status_name.include?(@fitout_status.name.downcase.titleize)
  position_exist = @fitout_status_position.include?(@fitout_status.position)

  respond_to do |format|
    if name_exist || position_exist
      format.html { redirect_to params[:fitout_status][:custom_redirect], danger: 'Status Or Order Already Exists' }
      format.json { render json: { error: 'Status Or Order Already Exists' }, status: :unprocessable_entity }
    else
      if @fitout_status.save
        format.html { redirect_to params[:fitout_status][:custom_redirect], notice: 'Status Created' }
        format.json { render json: @fitout_status, status: :created }
      else
        format.html { redirect_to params[:fitout_status][:custom_redirect], alert: 'Status Creation Failed' }
        format.json { render json: @fitout_status.errors, status: :unprocessable_entity }
      end
    end
  end
end


  def edit; end

  def update
    @fitout_status = FitoutStatus.find(params[:id])

    if @fitout_status.update(fitout_status_params)
      render json: { message: "Fitout status updated successfully", fitout_status: @fitout_status }, status: :ok
    else
      render json: { errors: @fitout_status.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @fitout_status.destroy
    redirect_to fitout_statuses_url, notice: 'Fitout status was successfully deleted.'
  end

  private

  def set_fitout_status
    @fitout_status = FitoutStatus.find(params[:id])
  end

  def fitout_status_params
    params.require(:fitout_status).permit(:society_id, :name, :color_code, :fixed_state, :is_active, :position, :of_phase, :of_atype)
  end
end
