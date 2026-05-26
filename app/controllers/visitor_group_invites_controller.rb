class VisitorGroupInvitesController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :verify_authenticity_token, only: [:guest_register_submit]
  before_action :find_guest_by_token, only: [:guest_register, :guest_register_submit]
  
  # POST /visitor_group_invites
  # Create group invite and add guest mobile numbers
  def create
    @visitor_group_invite = VisitorGroupInvite.new(
      site_id: current_user.current_site_id,
      invited_by_id: current_user.id
    )
    
    if @visitor_group_invite.save
      # Add guests
      mobile_numbers = params[:mobile_numbers] || []
      mobile_numbers.each do |number|
        @visitor_group_invite.visitor_group_invite_guests.create(
          mobile_number: number,
          vhost_id: current_user.id
        )
      end
      
      render json: {
        success: true,
        message: "Group invite created with #{mobile_numbers.count} guests",
        group_invite_id: @visitor_group_invite.id
      }
    else
      render json: {
        success: false,
        errors: @visitor_group_invite.errors.full_messages
      }, status: :unprocessable_entity
    end
  end
  
  # POST /visitor_group_invites/:id/send_invitations
  # Trigger SMS to all invited guests
  def send_invitations
    @visitor_group_invite = VisitorGroupInvite.find(params[:id])
    
    # Check authorization
    unless current_user.id == @visitor_group_invite.invited_by_id || current_user.admin?
      render json: { error: 'Unauthorized' }, status: :forbidden
      return
    end
    
    invited_guests = @visitor_group_invite.visitor_group_invite_guests.where(status: 'invited')
    
    if invited_guests.empty?
      render json: { success: false, message: 'No invited guests found' }
      return
    end
    
    # Queue background job
    VisitorGroupInviteJob.perform_later(@visitor_group_invite.id)
    
    render json: {
      success: true,
      message: "Sending invitations to #{invited_guests.count} guests",
      count: invited_guests.count
    }
  end
  
  # GET /visitor_group_invites/guest_register?token=xxx
  # Public registration form for guest
  def guest_register
    @invited_by = @guest.visitor_group_invite.invited_by
    @site = @guest.visitor_group_invite.site
  end
  
  # POST /visitor_group_invites/guest_register
  # Submit guest registration and create visitor pass
  def guest_register_submit
    @invited_by = @guest.visitor_group_invite.invited_by
    @site = @guest.visitor_group_invite.site
    
    # Create visitor pass
    visitor = Visitor.new(
      name: params[:name],
      contact_no: params[:mobile_number],
      email: params[:email],
      site_id: @site.id,
      purpose: params[:purpose] || "Group Invitation",
      frequency: 'Once',
      start_pass: Time.current,
      end_pass: Time.current + 1.day,
      status: true,
      visitor_type: 'group_invite',
      vhost_id: @guest.vhost_id,
      created_by_id: @invited_by.id
    )
    
    if visitor.save
      # Update guest record
      @guest.update(
        visitor_id: visitor.id,
        name: params[:name],
        email: params[:email],
        status: 'pass_generated'
      )
      
      respond_to do |format|
        format.json {
          render json: {
            success: true,
            message: "Visitor pass generated successfully!",
            visitor_id: visitor.id,
            qr_code_url: visitor.qr_code_image&.image&.url,
            invited_by: @invited_by.full_name
          }
        }
        format.html {
          flash[:notice] = "Visitor pass generated successfully! Invited by #{@invited_by.full_name}"
          render :guest_register_success
        }
      end
    else
      respond_to do |format|
        format.json {
          render json: {
            success: false,
            errors: visitor.errors.full_messages
          }, status: :unprocessable_entity
        }
        format.html {
          flash[:error] = visitor.errors.full_messages.join(', ')
          render :guest_register, status: :unprocessable_entity
        }
      end
    end
  end
  
  private
  
  def find_guest_by_token
    @guest = VisitorGroupInviteGuest.find_by(invitation_token: params[:token])
    
    unless @guest
      respond_to do |format|
        format.json { render json: { error: 'Invalid or expired invitation link' }, status: :not_found }
        format.html {
          flash[:error] = 'Invalid or expired invitation link'
          redirect_to root_path
        }
      end
    end
  end
end
