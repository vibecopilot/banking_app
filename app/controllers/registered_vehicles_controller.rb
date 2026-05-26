class RegisteredVehiclesController < ApplicationController
  include UserExt
  layout 'basic'
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_registered_vehicle, only: %i[ show edit update destroy ]

  # GET /registered_vehicles or /registered_vehicles.json
  def index
    @q = RegisteredVehicle.ransack(params[:q])
    base_scope = @q.result.where(site_id: @user.current_site_id).includes(:registered_vehicle_visits, :user, :created_by, :parking_configuration).order(created_at: :desc)
    @registered_vehicles = base_scope.page(params[:page]).per(params[:per_page] || 20)
  end

  # GET /registered_vehicles/1 or /registered_vehicles/1.json
  def show
  end

  # GET /registered_vehicles/new
  def new
    @registered_vehicle = RegisteredVehicle.new(
      registered_vehicle_params.merge(site_id: @user.current_site_id)

)
  end

  # GET /registered_vehicles/1/edit
  def edit
  end

  # POST /registered_vehicles or /registered_vehicles.json
  def create
    @registered_vehicle = RegisteredVehicle.new(registered_vehicle_params.merge(site_id: @user.current_site_id))
    respond_to do |format|
      if @registered_vehicle.save
        if params[:attachfiles].present?
          params[:attachfiles].each do |doc|
            Attachfile.create(image: doc, relation: "RegisteredVehicleDocument", relation_id: @registered_vehicle.id, active: 1)
          end
        end
        format.html { redirect_to @registered_vehicle, notice: "Registered vehicle was successfully created." }
        format.json { render :show, status: :created, location: @registered_vehicle }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @registered_vehicle.errors, status: :unprocessable_entity }
      end
    end
  end

  # Pending Approvals
  def pending_approvals
    @q = RegisteredVehicle.ransack(params[:q])
    base_scope = @q.result.where(site_id: @user.current_site_id, approved: "Pending").includes(:parking_configuration, :unit).order(created_at: :desc)
    @registered_vehicles = base_scope.page(params[:page]).per(params[:per_page] || 20)

    respond_to do |format|
      format.json {render 'pending_vehicles'}
    end
  end

  #Approve Requests

  def approve_request
    @registered_vehicle = RegisteredVehicle.find(params[:id])
    unless @user.user_type == 'pms_admin'
      return render json: { error: 'Unauthorized' }, status: :unauthorized
    end
    approved = ActiveModel::Type::Boolean.new.cast(params[:approved])
    approval_status = approved ? 'Approved' : 'Rejected'
    if @registered_vehicle.update(approved: approval_status)
      notify_vehicle_owner(@registered_vehicle, approval_status)
      render json: {
        message: "Vehicle #{approval_status.downcase} successfully",
        status: approval_status
      }, status: :ok
    else
      render json: {
        error: @registered_vehicle.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def get_dashboard_count
    site_id = params[:site_id].present? ? params[:site_id].to_i : @user.current_site_id
    @registered_vehicles = RegisteredVehicle.where(site_id: site_id).all.count
    @total_in = RegisteredVehicle.where(site_id: site_id).joins(:registered_vehicle_visits).where("registered_vehicle_visits.check_in IS NOT NULL AND registered_vehicle_visits.check_out IS NULL").distinct.count
    @total_out = RegisteredVehicle.where(site_id: site_id).joins(:registered_vehicle_visits).where("registered_vehicle_visits.check_in IS NOT NULL AND registered_vehicle_visits.check_out IS NOT NULL").distinct.count
    @todays_in = RegisteredVehicle.where(site_id: site_id).joins(:registered_vehicle_visits)
    .where(registered_vehicle_visits: {
             check_in: Time.zone.today.all_day, check_in: nil
    }).distinct.count
    @todays_out = RegisteredVehicle.where(site_id: site_id).joins(:registered_vehicle_visits).where(registered_vehicle_visits: {
                                                                                                      check_out: Time.zone.today.all_day
    }).distinct.count
    render json: {
      total_count: @registered_vehicles,
      todays_in: @todays_in,
      todays_out: @todays_out,
      total_in: @total_in,
      total_out: @total_out
    }
  end

  def get_registered_vehicles
    if params[:vehicle_number].present?
      @reg_vehicle = RegisteredVehicle.includes(:registered_vehicle_visits, :user, :created_by, :parking_configuration, :qr_code_image).find_by(vehicle_number: params[:vehicle_number])
      if @reg_vehicle.present?
        render 'get_registered_vehicle', status: :ok
      else
        render json: { message: "Vehicle Not Registered" }, status: :not_found
      end
    else
      render json: { message: "Vehicle Number Is Required" }, status: :bad_request
    end
  end

  # PATCH/PUT /registered_vehicles/1 or /registered_vehicles/1.json
  def update
    respond_to do |format|
      if @registered_vehicle.update(registered_vehicle_params)
        format.html { redirect_to @registered_vehicle, notice: "Registered vehicle was successfully updated." }
        format.json { render :show, status: :ok, location: @registered_vehicle }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @registered_vehicle.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /registered_vehicles/1 or /registered_vehicles/1.json
  def destroy
    @registered_vehicle.destroy
    respond_to do |format|
      format.html { redirect_to registered_vehicles_url, notice: "Registered vehicle was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  # Bulk Upload
  def import
    unless params[:file].present?
      return render json: { 
        success: false, 
        message: 'No file uploaded. Please upload a valid Excel file.' 
      }, status: :bad_request
    end

    @uploadds = RegisteredVehicle.import(params[:file], @user)
    respond_to do |format|
      format.html {
        fallback_url = registered_vehicles_path
        redirect_url = request.referrer.present? ? "#{request.referrer}#" : fallback_url
        redirect_to redirect_url, notice: "Successfully imported Registered Vehicles"
      }
      format.json { render json: @uploadds }
    end
  rescue => e
    respond_to do |format|
      format.html { 
        redirect_to registered_vehicles_path, alert: "Error importing vehicles: #{e.message}" 
      }
      format.json { 
        render json: { success: false, message: e.message, errors: [e.message] }, status: :unprocessable_entity 
      }
    end
  end

  # Download Sample File
  def download_sample
    file_path = Rails.root.join('public', 'sample_files', 'import_registered_vehicles.xlsx')

    if File.exist?(file_path)
      send_file(
        file_path,
        filename: "import_registered_vehicles.xlsx",
        type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
      )
    else
      render json: { error: "Sample file not found" }, status: :not_found
    end
  end

  private

  def notify_vehicle_owner(registered_vehicle, status)
    return unless registered_vehicle.user_id.present?

    user = User.find_by(id: registered_vehicle.user_id)
    return unless user

    device = UserDevice.where(user_id: user.id)
    return if device.blank?

    senddata = {
      title: "Vehicle Registration #{status}",
      message: "Your vehicle registration has been #{status.downcase}.",
      user_id: user.id,
      company_id: user&.site&.company_id,
      record_id: registered_vehicle.id
    }
    PushNotification.push_to_devices(device, senddata)
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_registered_vehicle
    @registered_vehicle = RegisteredVehicle.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def registered_vehicle_params
    params.require(:registered_vehicle).permit(:slot_number, :valid_till ,
                                               :vehicle_category, :vehicle_type, :sticker_number,
                                               :registration_number, :insurance_number,
                                               :insurance_valid_till, :category, :vehicle_number,
                                               :unit_id, :user_id, :created_by_id, :status, :site_id,
                                               :approved, :vehicle_in_out
                                               )
  end
end
