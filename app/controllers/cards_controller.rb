class CardsController < ApplicationController
  before_action :set_card, only: [:show, :edit, :update, :destroy]
  before_action :api_user, except: [:index, :show]

  def index
    @cards = Card.all
    
    if params[:user_id].present?
      @cards = @cards.where(user_id: params[:user_id])
    end

    if params[:company_code].present?
      @cards = @cards.where(company_code: params[:company_code])
    end

    if params[:tag_type].present?
      @cards = @cards.where(tag_type: params[:tag_type])
    end

    if params[:status].present?
      @cards = @cards.where(status: params[:status])
    end

    @cards = @cards.order(created_at: :desc).page(params[:page]).per(params[:per_page] || 20)

    respond_to do |format|
      format.json { render json: @cards }
      format.html
    end
  end

  def show
    respond_to do |format|
      format.json { render json: @card }
      format.html
    end
  end

  def fetch_and_save
    user = User.find_by(id: params[:user_id])
    
    unless user
      return render json: { success: false, error: 'User not found' }, status: :not_found
    end

    service = CardInventoryService.new(user, params[:company_id] || 56)
    result = service.fetch_and_save_cards

    respond_to do |format|
      if result[:success]
        format.json { render json: result, status: :ok }
      else
        format.json { render json: result, status: :unprocessable_entity }
      end
    end
  end

  def fetch_all_users_cards
    company_id = params[:company_id] || 56
    users = User.where(company_id: company_id, active: true)
    
    results = {
      total_users: users.count,
      successful: 0,
      failed: 0,
      details: []
    }

    users.find_each do |user|
      service = CardInventoryService.new(user, company_id)
      result = service.fetch_and_save_cards

      if result[:success]
        results[:successful] += 1
        results[:details] << { user_id: user.id, result: result }
      else
        results[:failed] += 1
        results[:details] << { user_id: user.id, error: result[:error] }
      end
    end

    render json: results, status: :ok
  end

  def assign_tag
    user = User.find_by(id: params[:user_id])
    
    unless user
      return render json: { success: false, error: 'User not found' }, status: :not_found
    end

    service = TagAssignmentService.new(user, params[:company_id] || 56)
    result = service.assign_tag

    respond_to do |format|
      if result[:success]
        format.json { render json: result, status: :ok }
      else
        format.json { render json: result, status: :unprocessable_entity }
      end
    end
  end

  def assign_tags_batch
    company_id = params[:company_id] || 56
    user_ids = params[:user_ids] || []
    
    results = {
      total_users: user_ids.count,
      successful: 0,
      failed: 0,
      details: []
    }

    user_ids.each do |user_id|
      user = User.find_by(id: user_id)
      next unless user.present?
      
      service = TagAssignmentService.new(user, company_id)
      result = service.assign_tag

      if result[:success]
        results[:successful] += 1
        results[:details] << { user_id: user_id, result: result }
      else
        results[:failed] += 1
        results[:details] << { user_id: user_id, error: result[:error] }
      end
    end

    render json: results, status: :ok
  end

  private

  def set_card
    @card = Card.find(params[:id])
  end
end
