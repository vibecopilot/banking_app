class UserDevicesController < ApplicationController
    include UserExt
  before_action :authenticate_user!, if: :check_user 
  before_action :api_user
  before_action :set_user
  before_action :set_user_device, only: %i[ show edit update destroy ]

  # GET /user_devices or /user_devices.json
 def index
    @user_devices = UserDevice.all
  end

  # GET /user_devices/1 or /user_devices/1.json
  def show
  end

  # GET /user_devices/new
  def new
    @user_device = UserDevice.new
  end

  # GET /user_devices/1/edit
  def edit
  end

  # POST /user_devices or /user_devices.json
  def create
    app_id = params[:user_device][:app_id]
    @device = @user.user_devices.where(device_id: params[:user_device][:device_id], gcm_key: params[:user_device][:gcm_key], app_id: params[:user_device][:app_id])
    if !@device.present?
      @user_device = @user.user_devices.build(user_device_params)

      respond_to do |format|
        if @user_device.save
          format.html { redirect_to @user_device, notice: 'User device was successfully created.' }
          format.json { render :show, status: :created, location: @user_device }
        else
          format.html { render :new }
          format.json { render json: @user_device.errors, status: :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
        @user_device = @device.first
        @user_device.update(user_device_params)
        format.html { redirect_to @device.first, notice: 'User device was successfully created.' }
        format.json { render :show, status: :created, location: @user_device }
      end
    end
  end

  # PATCH/PUT /user_devices/1 or /user_devices/1.json
  def update
    respond_to do |format|
      if @user_device.update(user_device_params)
        format.html { redirect_to @user_device, notice: "User device was successfully updated." }
        format.json { render :show, status: :ok, location: @user_device }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @user_device.errors, status: :unprocessable_entity }
      end
    end
  end

  def delete_devices
    @devices = UserDevice.where(user_id: current_user.id, device_id: params[:device_id], app_id: params[:app_id], gcm_key: params[:gcm_key])
    @devices.delete_all
    render json: {"deleted": true}
  end

  # DELETE /user_devices/1
  # DELETE /user_devices/1.json
  def destroy
    @user_device.update(:active => 0)
    respond_to do |format|
      format.html { redirect_to user_devices_url, notice: 'User device was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user_device
      @user_device = UserDevice.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def user_device_params
      params.require(:user_device).permit(:user_id, :device_id, :device_type, :gcm_key, :device_name, :device_os_version, :ios_sound, :app_id, :full_screen, :call)
    end
end
