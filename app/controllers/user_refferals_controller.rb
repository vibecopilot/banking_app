class UserRefferalsController < ApplicationController
  include UserExt
  layout 'basic'
  before_action :set_user_refferal, only: %i[ show edit update destroy ]
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user

  # GET /user_refferals or /user_refferals.json
  def index
    @user_refferals = UserRefferal.where(deleted: false).ransack(params[:q]).result
  end

  # GET /user_refferals/1 or /user_refferals/1.json
  def show
  end

  # GET /user_refferals/new
  def new
    @user_refferal = UserRefferal.new
  end

  # GET /user_refferals/1/edit
  def edit
  end

  # POST /user_refferals or /user_refferals.json
  def create
    @user_refferal = UserRefferal.new(user_refferal_params)

    respond_to do |format|
      if @user_refferal.save

        if params[:attachments].present?
          params[:attachments].each do |doc|
            Attachfile.create(image: doc, relation: "UserRefferal", relation_id: @user_refferal.id, active: 1)
          end
        end

        format.html { redirect_to @user_refferal, notice: "User refferal was successfully created." }
        format.json { render :show, status: :created, location: @user_refferal }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @user_refferal.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /user_refferals/1 or /user_refferals/1.json
  def update
    respond_to do |format|
      if @user_refferal.update(user_refferal_params)
        format.html { redirect_to @user_refferal, notice: "User refferal was successfully updated." }
        format.json { render :show, status: :ok, location: @user_refferal }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @user_refferal.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /user_refferals/1 or /user_refferals/1.json
  def destroy
    @user_refferal.destroy
    respond_to do |format|
      format.html { redirect_to user_refferals_url, notice: "User refferal was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_user_refferal
    @user_refferal = UserRefferal.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def user_refferal_params
    params.require(:user_refferal).permit(:from_user_id, :refferal_type, :to_user_id, :date_time, :name, :mobile, :email, :business, :amount)
  end
end
