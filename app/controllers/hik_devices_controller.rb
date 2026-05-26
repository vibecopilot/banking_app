# app/controllers/hik_devices_controller.rb
class HikDevicesController < ApplicationController
  before_action :set_hik_device, only: [:show, :update, :destroy, :api_call]

  # GET /hik_devices
  def index
    @hik_devices = HikDevice.all
    render json: @hik_devices
  end

  # GET /hik_devices/:id
  def show
    render json: @hik_device
  end

  # POST /hik_devices
  def create
    @hik_device = HikDevice.new(hik_device_params)
    if @hik_device.save
      render json: @hik_device, status: :created
    else
      render json: @hik_device.errors, status: :unprocessable_entity
    end
  end

  # PUT /hik_devices/:id
  def update
    if @hik_device.update(hik_device_params)
      render json: @hik_device
    else
      render json: @hik_device.errors, status: :unprocessable_entity
    end
  end

  # DELETE /hik_devices/:id
  def destroy
    @hik_device.destroy
    head :no_content
  end

  # POST /hik_devices/:id/api_call
  def api_call
    endpoint = params[:endpoint]
    method = params[:method] || :get
    payload = params[:payload]

    response = @hik_device.call_api(endpoint: endpoint, method: method, payload: payload)
    render json: response
  end


# GET /hik_devices/find_by_site/:site_id
  def find_by_site
    site = Site.find_by(id: params[:site_id]) || Site.find_by(name: params[:site_id])

    if site
      render json: site.hik_devices, status: :ok
    else
      render json: { error: "Site not found or no HikDevices associated" }, status: :not_found
    end
  end


  private

  def set_hik_device
    @hik_device = HikDevice.find(params[:id])
  end

  def hik_device_params
    params.require(:hik_device).permit(:name, :ip_address, :username, :password, :port, :building_id, :site_id)
  end
end
