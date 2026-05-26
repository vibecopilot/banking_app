class MomAttendeesController < ApplicationController
  before_action :set_mom_attendee, only: %i[ show edit update destroy ]

  # GET /mom_attendees or /mom_attendees.json
  def index
    @mom_attendees = MomAttendee.all
  end

  # GET /mom_attendees/1 or /mom_attendees/1.json
  def show
  end

  # GET /mom_attendees/new
  def new
    @mom_attendee = MomAttendee.new
  end

  # GET /mom_attendees/1/edit
  def edit
  end

  # POST /mom_attendees or /mom_attendees.json
  def create
    @mom_attendee = MomAttendee.new(mom_attendee_params)

    respond_to do |format|
      if @mom_attendee.save
        format.html { redirect_to @mom_attendee, notice: "Mom attendee was successfully created." }
        format.json { render :show, status: :created, location: @mom_attendee }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @mom_attendee.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /mom_attendees/1 or /mom_attendees/1.json
  def update
    respond_to do |format|
      if @mom_attendee.update(mom_attendee_params)
        format.html { redirect_to @mom_attendee, notice: "Mom attendee was successfully updated." }
        format.json { render :show, status: :ok, location: @mom_attendee }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @mom_attendee.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /mom_attendees/1 or /mom_attendees/1.json
  def destroy
    @mom_attendee.destroy
    respond_to do |format|
      format.html { redirect_to mom_attendees_url, notice: "Mom attendee was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_mom_attendee
      @mom_attendee = MomAttendee.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def mom_attendee_params
      params.require(:mom_attendee).permit(:mom_detail_id, :name, :organization, :role, :email, :company_tag_name, :attendees_id, :attendees_type)
    end
end
