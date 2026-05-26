class TaxRatesController < ApplicationController
  include UserExt
  layout 'basic'
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_tax_rate, only: %i[show edit update destroy]

  # GET /tax_rates or /tax_rates.json
  def index
    @q = TaxRate.for_site(@user.current_site_id)
      .includes(:ledger)
      .ransack(params[:q])
    
    @tax_rates = @q.result
      .order(tax_type: :asc, rate: :asc)
      .paginate(page: params[:page], per_page: params[:per_page] || 50)
    
    respond_to do |format|
      format.html
      format.json { render :index }
    end
  end

  # GET /tax_rates/1 or /tax_rates/1.json
  def show
    respond_to do |format|
      format.html
      format.json { render :show }
    end
  end

  # GET /tax_rates/new
  def new
    @tax_rate = TaxRate.new
  end

  # GET /tax_rates/1/edit
  def edit
  end

  # POST /tax_rates or /tax_rates.json
  def create
    @tax_rate = TaxRate.new(tax_rate_params)
    @tax_rate.site_id = @user.current_site_id

    respond_to do |format|
      if @tax_rate.save
        format.html { redirect_to tax_rates_path, notice: 'Tax rate was successfully created.' }
        format.json { render :show, status: :created, location: @tax_rate }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @tax_rate.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tax_rates/1 or /tax_rates/1.json
  def update
    respond_to do |format|
      if @tax_rate.update(tax_rate_params)
        format.html { redirect_to tax_rates_path, notice: 'Tax rate was successfully updated.' }
        format.json { render :show, status: :ok, location: @tax_rate }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @tax_rate.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tax_rates/1 or /tax_rates/1.json
  def destroy
    @tax_rate.destroy
    respond_to do |format|
      format.html { redirect_to tax_rates_url, notice: 'Tax rate was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # GET /tax_rates/active
  def active
    @tax_rates = TaxRate.for_site(@user.current_site_id)
      .active
      .current
      .order(:tax_type, :rate)
    
    respond_to do |format|
      format.json { render :index }
    end
  end

  # POST /tax_rates/seed_defaults
  def seed_defaults
    TaxRate.seed_default_tax_rates(@user.current_site_id)
    
    respond_to do |format|
      format.html { redirect_to tax_rates_path, notice: 'Default tax rates created successfully.' }
      format.json { render json: { message: 'Default tax rates created successfully' }, status: :ok }
    end
  end

  private

  def set_tax_rate
    @tax_rate = TaxRate.find(params[:id])
  end

  def tax_rate_params
    params.require(:tax_rate).permit(:name, :tax_type, :rate, :ledger_id, :description, 
                                      :active, :effective_from, :effective_to)
  end
end
