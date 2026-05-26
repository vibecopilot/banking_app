class MailRoomInboundsController < ApplicationController
  include UserExt
  layout 'basic'
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_mail_room_inbound, only: %i[ show edit update destroy ]

  # GET /mail_room_inbounds or /mail_room_inbounds.json
  def index
    @mail_room_inbounds = MailRoomInbound.all
  end

  # GET /mail_room_inbounds/1 or /mail_room_inbounds/1.json
  def show
  end

  # GET /mail_room_inbounds/new
  def new
    @mail_room_inbound = MailRoomInbound.new
  end

  # GET /mail_room_inbounds/1/edit
  def edit
  end

  # POST /mail_room_inbounds or /mail_room_inbounds.json
  def create
    @mail_room_inbound = MailRoomInbound.new(mail_room_inbound_params)

    respond_to do |format|
      if @mail_room_inbound.save
        format.html { redirect_to @mail_room_inbound, notice: "Mail room inbound was successfully created." }
        format.json { render :show, status: :created, location: @mail_room_inbound }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @mail_room_inbound.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /mail_room_inbounds/1 or /mail_room_inbounds/1.json
  def update
    respond_to do |format|
      if @mail_room_inbound.update(mail_room_inbound_params)
        format.html { redirect_to @mail_room_inbound, notice: "Mail room inbound was successfully updated." }
        format.json { render :show, status: :ok, location: @mail_room_inbound }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @mail_room_inbound.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /mail_room_inbounds/1 or /mail_room_inbounds/1.json
  def destroy
    @mail_room_inbound.destroy
    respond_to do |format|
      format.html { redirect_to mail_room_inbounds_url, notice: "Mail room inbound was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_mail_room_inbound
      @mail_room_inbound = MailRoomInbound.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def mail_room_inbound_params
      params.require(:mail_room_inbound).permit(:vendor_id, :receiving_date, :sender, :mobile_number, :awb_number, :company, :company_address_1, :company_address_2, :state, :city, :pincode, :mail_inbound_type, :receipant_name,:unit, :department_id, :mark_as_collected,:entity,:status, :aging, :collect_on, :collect_by_id,:created_by_id)
    end
end
