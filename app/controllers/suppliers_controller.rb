class SuppliersController < ApplicationController
  include UserExt
  before_action :api_user
  before_action :set_supplier, only: %i[ show edit update destroy ]

  def index
    @suppliers = Supplier.where(site_id: @user.current_site_id).order(created_at: :DESC)
    @suppliers = @suppliers.ransack(params[:q]).result
  end

  def show
  end

  def new
    @supplier = Supplier.new
  end

  def edit
  end

  def create
    @supplier = Supplier.new(supplier_params)
    @supplier.created_by_id = @user.id
    @supplier.site_id = @user.current_site_id

    respond_to do |format|
      if @supplier.save
        format.json { render :show, status: :created, location: @supplier }
      else
        format.json { render json: @supplier.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @supplier.update(supplier_params)
        format.json { render :show, status: :ok, location: @supplier }
      else
        format.json { render json: @supplier.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @supplier.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private

  def set_supplier
    @supplier = Supplier.find(params[:id])
  end

  def supplier_params
    params.require(:supplier).permit(:name, :contact_person, :email, :phone, :address, :status)
  end
end
