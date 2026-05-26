class Pms::Manage::CostApprovalsController < ApplicationController
  include UserExt
  layout 'pms_new_layout'
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :find_cost_approval, only: :update
  def create
  	@cost_approval = CostApproval.new
  	@cost_approval.assign_attributes(cost_approval_params)
    @cost_approval.resource = @user.site
    @cost_approval.created_by_id = @user.id
    @cost_approval.level = 'user_level'
    @cost_approval.active = true
  	if @cost_approval.save
  		redirect_to "/pms/admin/helpdesk_categories", notice: 'Cost Approval Created Successfully'
  	else
  		redirect_to "/pms/admin/helpdesk_categories", alert: @cost_approval.errors.full_messages.join(", ")
  	end
  end


  def costapprequpdate
      @result = CostApprovalRequest.find_by(id: params[:id])
      @approval_history = CostApprovalHistory.where(cost_approval_request_id: params[:id]).last.update(status: "cancelled",updated_by_id: @user.id)
      if @result.update(active: false,status: "cancelled")
        redirect_to "/pms/admin/complaints/#{@result.complaint.id}", notice: 'Cost Approval Request has been cancelled successfully'
      else
        redirect_to "/pms/admin/complaints/#{@result.complaint.id}", alert: @result.errors.full_messages.join(", ")
      end        
  end

  def update
    if @cost_approval.update_columns(active: params[:cost_approval][:active])
      redirect_to "/pms/admin/helpdesk_categories", notice: 'Cost Approval rule has been deleted successfully'
    else
      redirect_to "/pms/admin/helpdesk_categories", alert: @cost_approval.errors.full_messages.join(", ")
    end
  end

  private


  def find_cost_approval
    @cost_approval = CostApproval.find_by(id: params[:id])
  end

  def cost_approval_params
  	params.require(:cost_approval).permit(
  		:related_to, :cost_from, :cost_to, :category_type_id, :resource_id, :resource_type, :cost_unit, :active, :level, :no_approval_required_from, :no_approval_required_to,
  		cost_approval_levels_attributes: [:id, :name, :access_level, :active, escalate_to_users: []]
  	)
  end
end