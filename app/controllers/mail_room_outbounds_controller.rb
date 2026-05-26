class MailRoomOutboundsController < ApplicationController
  include UserExt
  layout 'basic'
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_mail_room_outbound, only: %i[ show edit update destroy ]

  # GET /mail_room_outbounds or /mail_room_outbounds.json
  def index
    @mail_room_outbounds = MailRoomOutbound.all
  end

  # GET /mail_room_outbounds/1 or /mail_room_outbounds/1.json
  def show
  end

  # GET /mail_room_outbounds/new
  def new
    @mail_room_outbound = MailRoomOutbound.new
  end

  # GET /mail_room_outbounds/1/edit
  def edit
  end

  # POST /mail_room_outbounds or /mail_room_outbounds.json
  def create
    @mail_room_outbound = MailRoomOutbound.new(mail_room_outbound_params)

    respond_to do |format|
      if @mail_room_outbound.save
        format.html { redirect_to @mail_room_outbound, notice: "Mail room outbound was successfully created." }
        format.json { render :show, status: :created, location: @mail_room_outbound }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @mail_room_outbound.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /mail_room_outbounds/1 or /mail_room_outbounds/1.json
  def update
    respond_to do |format|
      if @mail_room_outbound.update(mail_room_outbound_params)
        format.html { redirect_to @mail_room_outbound, notice: "Mail room outbound was successfully updated." }
        format.json { render :show, status: :ok, location: @mail_room_outbound }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @mail_room_outbound.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /mail_room_outbounds/1 or /mail_room_outbounds/1.json
  def destroy
    @mail_room_outbound.destroy
    respond_to do |format|
      format.html { redirect_to mail_room_outbounds_url, notice: "Mail room outbound was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_mail_room_outbound
      @mail_room_outbound = MailRoomOutbound.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def mail_room_outbound_params
      params.require(:mail_room_outbound).permit(:vendor_id, :sending_date, :sender_id, :recipient_name, :mobile_number, :awb_number, :unit, :recipient_email_id, :recipient_address_1,  :recipient_address_2, :state, :city, :pincode, :mail_outbound_type, :created_by_id,:entity,:status,:collect_by_id,:mark_as_collected,:recieved_by_id,:company,:company_address_1,:company_address_2)
    end
end
