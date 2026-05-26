class QrVerificationsController < ApplicationController
  include UserExt
  layout 'basic'
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_qr_verification, only: %i[show edit update destroy check_in check_out status]

  # GET /qr_verifications or /qr_verifications.json
  def index
    @q = QrVerification.for_site(@user.current_site_id)
      .includes(:generated_by, :checked_in_by, :checked_out_by)
      .ransack(params[:q])
    
    @qr_verifications = @q.result
      .order(created_at: :desc)
      .paginate(page: params[:page], per_page: params[:per_page] || 50)

    respond_to do |format|
      format.html
      format.json { render :index }
    end
  end

  # GET /qr_verifications/1 or /qr_verifications/1.json
  def show
    respond_to do |format|
      format.html
      format.json { render :show }
    end
  end

  # GET /qr_verifications/new
  def new
    @qr_verification = QrVerification.new
    @qr_verification.expected_time = Time.current
  end

  # GET /qr_verifications/1/edit
  def edit
  end

  # POST /qr_verifications or /qr_verifications.json
  # Generate a new QR code
  def create
    @qr_verification = QrVerification.new(qr_verification_params)
    @qr_verification.site_id = @user.current_site_id
    @qr_verification.generated_by = @user

    respond_to do |format|
      if @qr_verification.save
        format.html { redirect_to @qr_verification, notice: "QR verification code was successfully created." }
        format.json { render :show, status: :created, location: @qr_verification }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @qr_verification.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /qr_verifications/1 or /qr_verifications/1.json
  def update
    if @qr_verification.checked_in? || @qr_verification.checked_out?
      respond_to do |format|
        format.html { redirect_to @qr_verification, alert: 'Cannot update a checked-in or checked-out QR code.' }
        format.json { render json: { error: 'Cannot update a checked-in or checked-out QR code' }, status: :unprocessable_entity }
      end
      return
    end

    respond_to do |format|
      if @qr_verification.update(qr_verification_params)
        format.html { redirect_to @qr_verification, notice: "QR verification was successfully updated." }
        format.json { render :show, status: :ok, location: @qr_verification }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @qr_verification.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /qr_verifications/1 or /qr_verifications/1.json
  def destroy
    if @qr_verification.checked_in? || @qr_verification.checked_out?
      respond_to do |format|
        format.html { redirect_to qr_verifications_url, alert: 'Cannot delete a checked-in or checked-out QR code.' }
        format.json { render json: { error: 'Cannot delete a checked-in or checked-out QR code' }, status: :unprocessable_entity }
      end
      return
    end

    @qr_verification.destroy
    respond_to do |format|
      format.html { redirect_to qr_verifications_url, notice: "QR verification was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  # POST /qr_verifications/verify
  # Verify and check-in using QR code
  def verify
    @qr_verification = QrVerification.find_by(code: params[:code])

    if @qr_verification.nil?
      respond_to do |format|
        format.html { redirect_to qr_verifications_url, alert: 'Invalid QR code.' }
        format.json { render json: { success: false, error: 'Invalid QR code' }, status: :not_found }
      end
      return
    end

    result = @qr_verification.check_in!(@user, check_in_at: params[:check_in_at])

    respond_to do |format|
      if result[:success]
        format.html { redirect_to @qr_verification, notice: result[:message] }
        format.json { render json: { success: true, message: result[:message], qr_verification: @qr_verification }, status: :ok }
      else
        format.html { redirect_to @qr_verification, alert: result[:error] }
        format.json { render json: { success: false, error: result[:error] }, status: :unprocessable_entity }
      end
    end
  end

  # POST /qr_verifications/:id/check_in
  # Check-in using QR verification ID
  def check_in
    result = @qr_verification.check_in!(@user, check_in_at: params[:check_in_at])

    respond_to do |format|
      if result[:success]
        format.html { redirect_to @qr_verification, notice: result[:message] }
        format.json { render json: { success: true, message: result[:message], qr_verification: @qr_verification }, status: :ok }
      else
        format.html { redirect_to @qr_verification, alert: result[:error] }
        format.json { render json: { success: false, error: result[:error] }, status: :unprocessable_entity }
      end
    end
  end

  # POST /qr_verifications/:id/check_out
  # Check-out using QR verification ID
  def check_out
    result = @qr_verification.check_out!(@user, check_out_at: params[:check_out_at])

    respond_to do |format|
      if result[:success]
        format.html { redirect_to @qr_verification, notice: result[:message] }
        format.json { render json: { success: true, message: result[:message], qr_verification: @qr_verification }, status: :ok }
      else
        format.html { redirect_to @qr_verification, alert: result[:error] }
        format.json { render json: { success: false, error: result[:error] }, status: :unprocessable_entity }
      end
    end
  end

  # GET /qr_verifications/:id/status
  # Get current status of QR code
  def status
    respond_to do |format|
      format.json do
        render json: {
          id: @qr_verification.id,
          code: @qr_verification.code,
          status: @qr_verification.status,
          valid_for_checkin: @qr_verification.valid_for_checkin?,
          checked_in: @qr_verification.checked_in?,
          checked_in_at: @qr_verification.checked_in_at,
          checked_out: @qr_verification.checked_out?,
          checked_out_at: @qr_verification.checked_out_at,
          expected_time: @qr_verification.expected_time,
          valid_till: @qr_verification.valid_till,
          time_remaining: @qr_verification.time_remaining,
          generated_by: @qr_verification.generated_by&.name,
          checked_in_by: @qr_verification.checked_in_by&.name,
          checked_out_by: @qr_verification.checked_out_by&.name
        }
      end
    end
  end

  private

  def set_qr_verification
    @qr_verification = QrVerification.find(params[:id])
  end

  def qr_verification_params
    params.require(:qr_verification).permit(:expected_time, :validity_minutes, :purpose, :notes)
  end
end
