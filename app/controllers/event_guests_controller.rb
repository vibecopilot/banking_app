class EventGuestsController < ApplicationController
  before_action :set_event_guest, only: %i[ show edit update destroy ]

  # GET /event_guests or /event_guests.json
  def index
    @event_guests = EventGuest.all
  end

  # GET /event_guests/1 or /event_guests/1.json
  def show
  end

  # GET /event_guests/new
  def new
    @event_guest = EventGuest.new
  end

  # GET /event_guests/1/edit
  def edit
  end

  # POST /event_guests or /event_guests.json
  def create
    @event_guest = EventGuest.new(event_guest_params)

    respond_to do |format|
      if @event_guest.save
        format.html { redirect_to @event_guest, notice: "Event guest was successfully created." }
        format.json { render :show, status: :created, location: @event_guest }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @event_guest.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /event_guests/1 or /event_guests/1.json
  def update
    respond_to do |format|
      if @event_guest.update(event_guest_params)
        format.html { redirect_to @event_guest, notice: "Event guest was successfully updated." }
        format.json { render :show, status: :ok, location: @event_guest }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @event_guest.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /event_guests/1 or /event_guests/1.json
  def destroy
    @event_guest.destroy
    respond_to do |format|
      format.html { redirect_to event_guests_url, notice: "Event guest was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_event_guest
      @event_guest = EventGuest.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def event_guest_params
      params.require(:event_guest).permit(:event_id, :user_id,:name, :rsvp, :company_name, :email, :mobile, :business, :rules, :charges, :industry)
    end
end
