# app/controllers/visitor_staff_category_controller.rb
class VisitorStaffCategoryController < ApplicationController
  include UserExt
  layout 'basic'
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user

  def index
    @q = GenericSubInfo.ransack(params[:q])
    @categories = @q.result.joins(:generic_info).where(generic_infos: { site_id: params[:site_id] || @user.current_site_id }, generic_info_id: category_info.id)
    respond_to do |format|
      format.json {render 'generic_infos/staff_category'}
    end
    
    # render json: {
    #   success: true,
    #   total_count: @categories.count,
    #   categories: @categories.map { |c| { id: c.id, name: c.name } }
    # }
  end

  def show
    category = GenericSubInfo.find_by(id: params[:id], generic_info_id: category_info.id)
    if category
      render json: { success: true, category: { id: category.id, name: category.name } }
    else
      render json: { success: false, message: 'Category not found' }, status: :not_found
    end
  end

  def create
    category = GenericSubInfo.new(name: params[:name], generic_info_id: category_info.id)
    if category.save
      render json: { success: true, id: category.id, name: category.name }
    else
      render json: { success: false }, status: :unprocessable_entity
    end
  end

  def update
    category = GenericSubInfo.find(params[:id])
    if category.update(name: params[:name])
      render json: { success: true }
    else
      render json: { success: false }, status: :unprocessable_entity
    end
  end

  def destroy
    category = GenericSubInfo.find(params[:id])

    if Visitor.exists?(visitor_staff_category_id: category.id)
      render json: { success: false, message: 'Cannot delete category with associated visitors' }, status: :unprocessable_entity
    else
      if category.destroy
        render json: { success: true, id: category.id, name: category.name }
      else
        render json: { success: false, message: 'Failed to delete category' }, status: :unprocessable_entity
      end
    end
  end

  private

  def category_info
    @category_info ||= GenericInfo.find_or_create_by(info_type: 'visitor_staff_category', site_id: @user.current_site_id)
  end
end
