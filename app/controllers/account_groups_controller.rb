class AccountGroupsController < ApplicationController
  include UserExt
  layout 'basic'
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_account_group, only: %i[show edit update destroy]

  # GET /account_groups or /account_groups.json
  def index
    @q = AccountGroup.for_site(@user.current_site_id).ransack(params[:q])
    @account_groups = @q.result
      .includes(:parent, :children, :ledgers)
      .ordered_by_type
      .paginate(page: params[:page], per_page: params[:per_page] || 50)
    
    respond_to do |format|
      format.html
      format.json { render :index }
    end
  end

  # GET /account_groups/1 or /account_groups/1.json
  def show
    respond_to do |format|
      format.html
      format.json { render :show }
    end
  end

  # GET /account_groups/new
  def new
    @account_group = AccountGroup.new
  end

  # GET /account_groups/1/edit
  def edit
  end

  # POST /account_groups or /account_groups.json
  def create
    @account_group = AccountGroup.new(account_group_params)
    @account_group.site_id = @user.current_site_id

    respond_to do |format|
      if @account_group.save
        format.html { redirect_to account_groups_path, notice: 'Account group was successfully created.' }
        format.json { render :show, status: :created, location: @account_group }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @account_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /account_groups/1 or /account_groups/1.json
  def update
    respond_to do |format|
      if @account_group.update(account_group_params)
        format.html { redirect_to account_groups_path, notice: 'Account group was successfully updated.' }
        format.json { render :show, status: :ok, location: @account_group }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @account_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /account_groups/1 or /account_groups/1.json
  def destroy
    if @account_group.destroy
      respond_to do |format|
        format.html { redirect_to account_groups_url, notice: 'Account group was successfully destroyed.' }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to account_groups_url, alert: @account_group.errors.full_messages.join(', ') }
        format.json { render json: { errors: @account_group.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  # POST /account_groups/seed_defaults
  def seed_defaults
    AccountGroup.seed_default_groups(@user.current_site_id)
    
    respond_to do |format|
      format.html { redirect_to account_groups_path, notice: 'Default account groups created successfully.' }
      format.json { render json: { message: 'Default account groups created successfully' }, status: :ok }
    end
  end

  private

  def set_account_group
    @account_group = AccountGroup.find(params[:id])
  end

  def account_group_params
    params.require(:account_group).permit(:name, :code, :group_type, :parent_id, :description, :active)
  end
end
