class BusinessCardsController < ApplicationController
   include UserExt
  layout 'basic'
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_business_card, only: %i[ show edit update destroy ]

  # GET /business_cards or /business_cards.json
  def index
    @business_cards = BusinessCard.where(site_id: @user.current_site_id)
  end

  # GET /business_cards/1 or /business_cards/1.json
  def show
  end
  def get_for_user
    if @user.present?
      business_card = BusinessCard.find_by(created_by: @user.id)

      # if business_card
        render json: {
          id: business_card&.id,
          full_name: business_card&.full_name || @user.fullname ,
          profession: business_card&.profession,
          contact_number: business_card&.contact_number|| @user.mobile,
          email_id: business_card&.email_id || @user.email,
          website_url: business_card&.website_url,
          address: business_card&.address || @user.user_address,
          created_at: business_card&.created_at,
          updated_at: business_card&.updated_at,
          created_by: business_card&.user&.fullname,
          document_url: business_card&.image&.document_url 
        }
      # else
      #   render json: { error: "Business card not found" }, status: :not_found
      # end
    else
      render json: { error: "User not found" }, status: :not_found
    end
  end


  # GET /business_cards/new
  def new
    @business_card = BusinessCard.new
  end

  # GET /business_cards/1/edit
  def edit
  end

  # POST /business_cards or /business_cards.json
  def create
    @business_card = BusinessCard.new(business_card_params)
    @business_card.site_id = @user.current_site_id
    @business_card.created_by = @user.id

    respond_to do |format|
      if @business_card.save
        if params[:attachment].present?
          Attachfile.create(image: params[:attachment], relation: "BusinessCard", relation_id: @business_card.id, active: 1)
        end
        format.html { redirect_to @business_card, notice: "Business card was successfully created." }
        format.json { render :show, status: :created, location: @business_card }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @business_card.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /business_cards/1 or /business_cards/1.json
  def update
    respond_to do |format|
      if @business_card.update(business_card_params)
        format.html { redirect_to @business_card, notice: "Business card was successfully updated." }
        format.json { render :show, status: :ok, location: @business_card }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @business_card.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /business_cards/1 or /business_cards/1.json
  def destroy
    @business_card.destroy
    respond_to do |format|
      format.html { redirect_to business_cards_url, notice: "Business card was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_business_card
      @business_card = BusinessCard.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def business_card_params
      params.require(:business_card).permit(:full_name, :profession, :contact_number, :email_id, :website_url, :address,:created_by)
    end
end
