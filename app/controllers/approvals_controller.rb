class ApprovalsController < ApplicationController
  include UserExt
  protect_from_forgery with: :null_session
  layout 'basic'
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_approval, only: %i[ show edit update destroy decide ]

  # GET /approvals or /approvals.json
  def index
    @approvals = Approval.where(site_id: @user.current_site_id)
                         .includes(:approval_levels)
                         .ransack(params[:q]).result
  end

  # GET /approvals/1 or /approvals/1.json
  def show
  end

  # GET /approvals/new
  def new
    @approval = Approval.new
  end

  # GET /approvals/1/edit
  def edit
  end

  # POST /approvals or /approvals.json
  def create
    @approval = Approval.new(approval_params)
    @approval.site_id = @user.current_site_id
    @approval.user_id = @user.id

    if @approval.resource_type == "quotation" && @approval.resource_id.present?
      quotation = Quotation.find_by(id: @approval.resource_id)
      @approval.total_amount = quotation&.total_amount || 0

      if @approval.status != "approved"
        templates = ApprovalLevel.where(site_id: @user.current_site_id, approval_id: nil)
                                  .order(:order)
        amount = @approval.total_amount.to_f

        @approval.approval_levels = []
        if templates.any?
          templates.each_with_index do |tmpl, i|
            next unless tmpl.threshold.nil? || i == 0 || amount >= tmpl.threshold.to_f
            @approval.approval_levels.build(
              name: tmpl.name,
              user_id: tmpl.user_id,
              order: i,
              threshold: tmpl.threshold,
              decision: "pending"
            )
          end
        else
          thresholds = [5000, 25000, 100000]
          level_names = ["Level 1", "Level 2", "Level 3"]
          thresholds.each_with_index do |thresh, i|
            if i == 0 || amount >= thresh
              @approval.approval_levels.build(
                name: level_names[i],
                order: i,
                threshold: thresh,
                decision: "pending"
              )
            end
          end
        end
      end
    end

    respond_to do |format|
      if @approval.save
        format.html { redirect_to params[:cusdirect] || @approval, notice: "Approval was successfully created." }
        format.json { render :show, status: :created, location: @approval }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @approval.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /approvals/1/decide
  def decide
    decision = params[:decision]
    comment = params[:comment]
    levels = @approval.approval_levels.to_a
    current = @approval.current_level || 0
    level = levels[current]

    return render json: { error: "No level at index #{current}" }, status: :unprocessable_entity unless level

    ActiveRecord::Base.transaction do
      level.update!(decision: decision, comment: comment, acted_at: Time.current)

      case decision
      when "approved"
        if current + 1 >= levels.length
          @approval.update!(status: "approved", current_level: current)
        else
          @approval.update!(current_level: current + 1)
        end
      when "rejected"
        @approval.update!(status: "rejected")
      when "sent_back"
        @approval.update!(current_level: 0, status: "pending")
      end
    end

    render json: { approval: approval_json(@approval) }
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  # PATCH/PUT /approvals/1 or /approvals/1.json
  def update
    respond_to do |format|
      if @approval.update(approval_params)
        format.html { redirect_to params[:cusdirect] || @approval, notice: "Approval was successfully updated." }
        format.json { render :show, status: :ok, location: @approval }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @approval.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /approvals/1 or /approvals/1.json
  def destroy
    @approval.destroy
    respond_to do |format|
      format.html { redirect_to approvals_url, notice: "Approval was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  # GET /approvals/template_levels.json
  def template_levels
    levels = ApprovalLevel.where(site_id: @user.current_site_id, approval_id: nil)
                          .includes(:user).order(:order)

    if levels.any?
      render json: levels.map { |l|
        {
          id: l.id,
          name: l.name,
          user_id: l.user_id,
          user_name: l.user&.full_name,
          order: l.order,
          threshold: (l.threshold || 0).to_f,
        }
      }
    else
      render json: [
        { id: 0, name: "Level 1", user_id: nil, user_name: nil, order: 0, threshold: 5000 },
        { id: 0, name: "Level 2", user_id: nil, user_name: nil, order: 1, threshold: 25000 },
        { id: 0, name: "Level 3", user_id: nil, user_name: nil, order: 2, threshold: 100000 },
      ]
    end
  end

  # POST /add_approval_level
  def add_level
    @level = ApprovalLevel.new(approval_level_params)
    @level.site_id ||= @user.current_site_id

    respond_to do |format|
      if @level.save
        format.html { redirect_to request.referer || sites_path, notice: "Approval level added." }
        format.json { render json: @level, status: :created }
      else
        format.html { redirect_to request.referer || sites_path, alert: @level.errors.full_messages.join(", ") }
        format.json { render json: @level.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /approval_levels/:id
  def destroy_level
    level = ApprovalLevel.find(params[:id])
    level.destroy
    render json: { success: true }
  end

  private

  def approval_json(approval)
    {
      id: approval.id,
      refType: approval.resource_type&.downcase || "general",
      refId: "#{approval.resource_type&.first(3)&.upcase || 'REF'}-#{approval.resource_id}".gsub(" ", ""),
      title: approval.comments || "Approval ##{approval.id}",
      amount: approval.total_amount&.to_f || 0,
      currentLevel: approval.current_level || 0,
      status: approval.status || "pending",
      createdAt: approval.created_at,
      levels: approval.approval_levels.order(:order).map.with_index do |l, i|
        {
          id: "LV-#{l.id}",
          approver: l.name.presence || User.find_by(id: l.user_id)&.full_name || "User ##{l.user_id}",
        threshold: (l.threshold || 0).to_f,
          decision: i == (approval.current_level || 0) && approval.status == "pending" ? "pending" : (l.decision.presence || "pending"),
          comment: l.comment,
          actedAt: l.acted_at,
        }
      end
    }
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_approval
    @approval = Approval.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def approval_params
    params.require(:approval).permit(:site_id, :user_id, :level_id, :status, :start_date, :end_date, :resource_id, :resource_type, :comments, :approved_by_id, :approver_comments, :current_level, :total_amount, approval_levels_attributes: %i[id name user_id order threshold decision comment _destroy])
  end
  def approval_level_params
    params.require(:approval_level).permit(:site_id, :user_id, :name, :order, :threshold)
  end
end
