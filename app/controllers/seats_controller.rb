class SeatsController < ApplicationController
  include UserExt
  before_action :set_seat, only: %i[ show edit update destroy ]

  # GET /seats or /seats.json
  def index
    @seats = Seat.where(site_id: @user.current_site_id)
  end

  # GET /seats/1 or /seats/1.json
  def show
  end

  # GET /seats/new
  def new
    @seat = Seat.new
  end

  # GET /seats/1/edit
  def edit
  end

  # POST /seats or /seats.json
  def create
    @seat = Seat.new(seat_params)

    respond_to do |format|
      if @seat.save
        format.html { redirect_to @seat, notice: "Seat was successfully created." }
        format.json { render :show, status: :created, location: @seat }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @seat.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /seats/1 or /seats/1.json
  def update
    respond_to do |format|
      if @seat.update(seat_params)
        format.html { redirect_to @seat, notice: "Seat was successfully updated." }
        format.json { render :show, status: :ok, location: @seat }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @seat.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /seats/1 or /seats/1.json
  def destroy
    @seat.destroy
    respond_to do |format|
      format.html { redirect_to seats_url, notice: "Seat was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_seat
      @seat = Seat.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def seat_params
      params.require(:seat).permit(:buiding_id, :floor_id, :unit_id, :seat, :no, :category_id, :site_id)
    end
end
