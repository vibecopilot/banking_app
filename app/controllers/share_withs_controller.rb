class ShareWithsController < ApplicationController
    include UserExt
  layout 'basic'
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_share_with, only: %i[ show edit update destroy ]

  # GET /share_withs or /share_withs.json
  def index
    @share_withs = ShareWith.where(user_id: @user.id)
  end

  # GET /share_withs/1 or /share_withs/1.json
  def show
  end

  # GET /share_withs/new
  def new
    @share_with = ShareWith.new
  end

  # GET /share_withs/1/edit
  def edit
  end

  # POST /share_withs or /share_withs.json
  def create
    @share_with = ShareWith.new(share_with_params)

    respond_to do |format|
      if @share_with.save
        format.html { redirect_to @share_with, notice: "Share with was successfully created." }
        format.json { render :show, status: :created, location: @share_with }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @share_with.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /share_withs/1 or /share_withs/1.json
  def update
    respond_to do |format|
      if @share_with.update(share_with_params)
        format.html { redirect_to @share_with, notice: "Share with was successfully updated." }
        format.json { render :show, status: :ok, location: @share_with }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @share_with.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /share_withs/1 or /share_withs/1.json
  def destroy
    @share_with.destroy
    respond_to do |format|
      format.html { redirect_to share_withs_url, notice: "Share with was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_share_with
      @share_with = ShareWith.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def share_with_params
      params.require(:share_with).permit(:user_id, :shared_by, :folder_id, :document_id)
    end
end
