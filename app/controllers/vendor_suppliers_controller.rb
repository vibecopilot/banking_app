# app/controllers/vendor_suppliers_controller.rb
class VendorSuppliersController < ApplicationController
  include UserExt
  layout 'basic'
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user

  def index
    suppliers = GenericSubInfo.where(generic_info_id: supplier_info.id)
    render json: { 
      success: true, 
      suppliers: suppliers.map { |s| { id: s.id, name: s.name } }
    }
  end

  def show
    supplier = GenericSubInfo.find_by(id: params[:id], generic_info_id: supplier_info.id)
    if supplier
      render json: { success: true, supplier: { id: supplier.id, name: supplier.name } }
    else
      render json: { success: false, message: 'Supplier not found' }, status: :not_found
    end
  end

  def create
    supplier = GenericSubInfo.new(name: params[:name], generic_info_id: supplier_info.id)
    if supplier.save
      render json: { success: true, id: supplier.id, name: supplier.name }
    else
      render json: { success: false }, status: :unprocessable_entity
    end
  end

  def update
    supplier = GenericSubInfo.find(params[:id])
    if supplier.update(name: params[:name])
      render json: { success: true }
    else
      render json: { success: false }, status: :unprocessable_entity
    end
  end

  def destroy
    supplier = GenericSubInfo.find(params[:id])
    
    if Vendor.exists?(vendor_supplier_id: supplier.id)
      render json: { success: false, message: 'Cannot delete supplier with associated vendors' }, status: :unprocessable_entity
    else
      if supplier.destroy
        render json: { success: true, id: supplier.id, name: supplier.name }
      else
        render json: { success: false, message: 'Failed to delete supplier' }, status: :unprocessable_entity
      end
    end
  end

  private

  def supplier_info
    @supplier_info ||= GenericInfo.find_or_create_by(info_type: 'vendor_supplier', site_id: @user.current_site_id)
  end
end