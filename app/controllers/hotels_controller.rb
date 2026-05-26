class HotelsController < ApplicationController
  include UserExt
  before_action :set_user

  before_action :set_hotel, only: %i[ show edit update destroy ]

  # GET /hotels or /hotels.json
  def index
    @hotels = Hotel.where(site_id: @user.current_site_id).ransack(params[:q]).result
    # Apply additional filter for booking_status if present
    if params[:booking_status].present?
      @hotels = @hotels.where(booking_status: params[:booking_status])
    end
    #@hotels = Hotel.all
  end

  # GET /hotels/1 or /hotels/1.json
  def show
  end

  # GET /hotels/new
  def new
    @hotel = Hotel.new
  end

  # GET /hotels/1/edit
  def edit
  end

  # POST /hotels or /hotels.json
  def create
    @hotel = Hotel.new(hotel_params)

    @hotel.booking_status = 'pending' if @hotel.booking_status.blank?
    @hotel.site_id = @user.current_site_id
    respond_to do |format|
      if @hotel.save
        format.html { redirect_to @hotel, notice: "Hotel was successfully created." }
        format.json { render :show, status: :created, location: @hotel }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @hotel.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /hotels/1 or /hotels/1.json
  def update
    respond_to do |format|
      if @hotel.update(hotel_params)
        format.html { redirect_to @hotel, notice: "Hotel was successfully updated." }
        format.json { render :show, status: :ok, location: @hotel }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @hotel.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /hotels/1 or /hotels/1.json
  def destroy
    @hotel.destroy
    respond_to do |format|
      format.html { redirect_to hotels_url, notice: "Hotel was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_hotel
      @hotel = Hotel.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def hotel_params
      params.require(:hotel).permit(:hotel_name, :location, :employee_id, :employee_name, :destination, :number_of_rooms, :room_type, :special_requests, :hotel_preferences, :check_in_date, :check_out_date, :booking_confirmation_number, :booking_certification_email, :booking_status, :manager_approval, :is_available, :site_id,:email,:mobile_no
)
    end
end
