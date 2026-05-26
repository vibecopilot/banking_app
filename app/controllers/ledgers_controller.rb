class LedgersController < ApplicationController
  include UserExt
  layout 'basic'
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_ledger, only: %i[show edit update destroy balance_sheet]

  # GET /ledgers or /ledgers.json
  def index
    @q = Ledger.for_site(@user.current_site_id)
      .includes(:account_group, :unit, :site)
      .ransack(params[:q])
    
    @ledgers = @q.result
      .order('account_groups.group_type ASC, ledgers.code ASC')
      .paginate(page: params[:page], per_page: params[:per_page] || 100)
    
    respond_to do |format|
      format.html
      format.json { render :index }
    end
  end

  # GET /ledgers/1 or /ledgers/1.json
  def show
    respond_to do |format|
      format.html
      format.json { render :show }
    end
  end

  # GET /ledgers/new
  def new
    @ledger = Ledger.new
  end

  # GET /ledgers/1/edit
  def edit
  end

  # POST /ledgers or /ledgers.json
  def create
    @ledger = Ledger.new(ledger_params)
    @ledger.site_id = @user.current_site_id

    respond_to do |format|
      if @ledger.save
        format.html { redirect_to ledgers_path, notice: 'Ledger was successfully created.' }
        format.json { render :show, status: :created, location: @ledger }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @ledger.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /ledgers/1 or /ledgers/1.json
  def update
    respond_to do |format|
      if @ledger.update(ledger_params)
        format.html { redirect_to ledgers_path, notice: 'Ledger was successfully updated.' }
        format.json { render :show, status: :ok, location: @ledger }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @ledger.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ledgers/1 or /ledgers/1.json
  def destroy
    if @ledger.destroy
      respond_to do |format|
        format.html { redirect_to ledgers_url, notice: 'Ledger was successfully destroyed.' }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to ledgers_url, alert: @ledger.errors.full_messages.join(', ') }
        format.json { render json: { errors: @ledger.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  # GET /ledgers/1/balance_sheet
  def balance_sheet
    from_date = params[:from_date] ? Date.parse(params[:from_date]) : Date.current.beginning_of_year
    to_date = params[:to_date] ? Date.parse(params[:to_date]) : Date.current
    
    @opening_balance = @ledger.opening_balance
    @closing_balance = @ledger.balance_as_on(to_date)
    
    @transactions = @ledger.journal_entry_lines
      .joins(:journal_entry)
      .where('journal_entries.entry_date BETWEEN ? AND ?', from_date, to_date)
      .where('journal_entries.status = ?', 'posted')
      .includes(:journal_entry)
      .order('journal_entries.entry_date ASC, journal_entries.id ASC')
    
    respond_to do |format|
      format.html
      format.json { render :balance_sheet }
    end
  end

  # POST /ledgers/seed_defaults
  def seed_defaults
    Ledger.seed_default_ledgers(@user.current_site_id)
    
    respond_to do |format|
      format.html { redirect_to ledgers_path, notice: 'Default ledgers created successfully.' }
      format.json { render json: { message: 'Default ledgers created successfully' }, status: :ok }
    end
  end

  # GET /ledgers/by_group
  def by_group
    account_group_id = params[:account_group_id]
    @ledgers = Ledger.for_site(@user.current_site_id)
      .where(account_group_id: account_group_id)
      .active
      .order(:name)
    
    respond_to do |format|
      format.json { render :index }
    end
  end

  # GET /ledgers/by_unit
  def by_unit
    unit_id = params[:unit_id]
    @ledgers = Ledger.for_site(@user.current_site_id)
      .for_unit(unit_id)
      .active
      .includes(:account_group, :unit)
      .order(:name)
    
    respond_to do |format|
      format.json { render :index }
    end
  end

  # GET /ledgers/organization_wide
  def organization_wide
    @ledgers = Ledger.for_site(@user.current_site_id)
      .where(unit_id: nil)
      .active
      .includes(:account_group)
      .order(:name)
    
    respond_to do |format|
      format.json { render :index }
    end
  end

  private

  def set_ledger
    @ledger = Ledger.find(params[:id])
  end

  def ledger_params
    params.require(:ledger).permit(:name, :code, :account_group_id, :unit_id, :description, 
                                    :opening_balance, :advance_amount, :ledger_type, :active)
  end
end
