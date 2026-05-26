class NoticesController < ApplicationController
  before_action :set_notice, only: %i[ show edit update destroy ]
   include UserExt
  layout 'basic'
  before_action :set_user

  # GET /notices or /notices.json
  def index
    notices_scope = Notice.where(site_id: @user.current_site_id)
    
    # Always refresh status for all notices before filtering
    notices_scope.find_each do |notice|
      old_status = notice.status
      notice.update_status_based_on_time
      notice.update_column(:status, notice.status) if notice.status != old_status
    end
    
    @notices = notices_scope.ransack(params[:q]).result.order(created_at: :desc)
  end

  # GET /notices/1 or /notices/1.json
  def show
  end

  # GET /notices/new
  def new
    @notice = Notice.new
  end

  # GET /notices/1/edit
  def edit
  end

  def communicaions_dashboard
    site_ids = params[:site_id].present? ? params[:site_id].to_i : @user.current_site_id
    @dashboard = {}

    # ===== Overall Communication Stats =====
    total_notices = Notice.where(site_id: site_ids, enabled: true)
    total_events = Event.where(site_id: site_ids, enabled: true)
    total_polls = Poll.joins(:group).where(groups: { site_id: site_ids })
    
    # Communication counts
    @dashboard[:all_communications_sent] = total_notices.count + total_events.count + total_polls.count
    @dashboard[:total_announcements] = total_notices.count
    @dashboard[:total_notifications] = total_events.count
    @dashboard[:total_polls] = total_polls.count

    # ===== User Stats =====
    active_users = User.where(current_site_id: site_ids, active: true)
    @dashboard[:active_users] = active_users.count

    # ===== Notice Stats =====
    notice_ids = total_notices.pluck(:id)
    notice_user_stats = NoticeUser.where(notice_id: notice_ids)
    
    notices_total = notice_user_stats.count
    notices_read = notice_user_stats.read.count
    notices_unread = notice_user_stats.unread.count
    notices_archived = notice_user_stats.archived.count

    # ===== Event Stats =====
    event_ids = total_events.pluck(:id)
    event_user_stats = EventUser.where(event_id: event_ids)
    
    events_total = event_user_stats.count
    events_read = event_user_stats.read.count
    events_unread = event_user_stats.unread.count
    events_archived = event_user_stats.archived.count

    # ===== Poll Stats =====
    poll_ids = total_polls.pluck(:id)
    poll_user_stats = PollUser.where(poll_id: poll_ids)
    poll_vote_stats = PollVote.where(poll_id: poll_ids)
    
    polls_total = poll_user_stats.count
    polls_read = poll_user_stats.read.count
    polls_unread = poll_user_stats.unread.count
    polls_archived = poll_user_stats.archived.count
    polls_voted = poll_vote_stats.select(:poll_user_id).distinct.count

    # ===== Aggregated Message Stats =====
    total_messages = notices_total + events_total + polls_total
    total_read = notices_read + events_read + polls_read
    total_unread = notices_unread + events_unread + polls_unread
    total_archived = notices_archived + events_archived + polls_archived
    
    read_rate = total_messages > 0 ? ((total_read.to_f / total_messages) * 100).round : 0

    @dashboard[:messages] = total_messages
    @dashboard[:read_count] = total_read
    @dashboard[:read_rate] = read_rate
    @dashboard[:unread] = total_unread
    @dashboard[:archived] = total_archived

    # ===== User Engagement =====
    # High engagement: users who read > 50% of their messages
    # Low engagement: users who read <= 50% of their messages
    engaged_user_ids = []
    low_engagement_count = 0
    high_engagement_count = 0

    active_users.find_each do |user|
      user_notice_stats = NoticeUser.where(notice_id: notice_ids, user_id: user.id)
      user_event_stats = EventUser.where(event_id: event_ids, user_id: user.id)
      user_poll_stats = PollUser.where(poll_id: poll_ids, user_id: user.id)
      
      user_total = user_notice_stats.count + user_event_stats.count + user_poll_stats.count
      user_read = user_notice_stats.read.count + user_event_stats.read.count + user_poll_stats.read.count
      
      if user_total > 0
        engagement_rate = (user_read.to_f / user_total) * 100
        if engagement_rate > 50
          high_engagement_count += 1
          engaged_user_ids << user.id
        else
          low_engagement_count += 1
        end
      end
    end

    @dashboard[:engaged_users] = engaged_user_ids.count
    @dashboard[:user_engagement] = {
      high_engagement: high_engagement_count,
      low_engagement: low_engagement_count
    }

    # ===== Breakdown by Communication Type =====
    @dashboard[:by_type] = {
      notices: {
        total: total_notices.count,
        messages_sent: notices_total,
        read: notices_read,
        unread: notices_unread,
        archived: notices_archived,
        read_rate: notices_total > 0 ? ((notices_read.to_f / notices_total) * 100).round : 0
      },
      events: {
        total: total_events.count,
        messages_sent: events_total,
        read: events_read,
        unread: events_unread,
        archived: events_archived,
        read_rate: events_total > 0 ? ((events_read.to_f / events_total) * 100).round : 0,
        rsvp_count: event_user_stats.where.not(rsvp: [nil, '']).count,
        checked_in_count: event_user_stats.where(checked_in: true).count
      },
      polls: {
        total: total_polls.count,
        messages_sent: polls_total,
        read: polls_read,
        unread: polls_unread,
        archived: polls_archived,
        read_rate: polls_total > 0 ? ((polls_read.to_f / polls_total) * 100).round : 0,
        votes_count: polls_voted
      }
    }

    # ===== By Category (using group_id) =====
    @dashboard[:by_category] = {}
    Group.where(site_id: site_ids).each do |group|
      group_notices = total_notices.where(group_id: group.id).count
      group_events = total_events.where(group_id: group.id).count
      group_polls = total_polls.where(group_id: group.id).count
      
      @dashboard[:by_category][group.group_name] = {
        notices: group_notices,
        events: group_events,
        polls: group_polls,
        total: group_notices + group_events + group_polls
      }
    end

    # ===== Monthly Trend (last 6 months) =====
    @dashboard[:monthly_trend] = []
    6.times do |i|
      month_start = (Date.current - i.months).beginning_of_month
      month_end = (Date.current - i.months).end_of_month
      
      month_notices = total_notices.where(created_at: month_start..month_end).count
      month_events = total_events.where(created_at: month_start..month_end).count
      month_polls = total_polls.where(created_at: month_start..month_end).count
      
      @dashboard[:monthly_trend] << {
        month: month_start.strftime("%B %Y"),
        notices: month_notices,
        events: month_events,
        polls: month_polls,
        total: month_notices + month_events + month_polls
      }
    end
    @dashboard[:monthly_trend].reverse!

    render json: @dashboard
  end

  # Mark notice as read for current user
  def mark_as_read
    notice_user = NoticeUser.find_by(notice_id: params[:id], user_id: @user.id)
    if notice_user
      notice_user.mark_as_read!
      render json: { success: true, message: "Notice marked as read" }
    else
      render json: { success: false, message: "Notice not found for user" }, status: :not_found
    end
  end

  # Mark notice as archived for current user
  def mark_as_archived
    notice_user = NoticeUser.find_by(notice_id: params[:id], user_id: @user.id)
    if notice_user
      notice_user.mark_as_archived!
      render json: { success: true, message: "Notice archived" }
    else
      render json: { success: false, message: "Notice not found for user" }, status: :not_found
    end
  end

  # Bulk mark as read
  def bulk_mark_as_read
    notice_ids = params[:notice_ids] || []
    NoticeUser.where(notice_id: notice_ids, user_id: @user.id).each(&:mark_as_read!)
    render json: { success: true, message: "#{notice_ids.count} notices marked as read" }
  end

  # Track email open via tracking pixel (1x1 transparent image)
  def track_email_open
    notice_id = params[:id]
    user_id = params[:user_id]
    
    if notice_id.present? && user_id.present?
      notice_user = NoticeUser.find_by(notice_id: notice_id, user_id: user_id)
      notice_user&.mark_as_read!
    end
    
    # Return a 1x1 transparent GIF
    send_data Base64.decode64("R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7"),
              type: "image/gif",
              disposition: "inline"
  end

  # Track email link click - marks as read and redirects to notice
  def track_email_click
    notice_id = params[:id]
    user_id = params[:user_id]
    
    if notice_id.present? && user_id.present?
      notice_user = NoticeUser.find_by(notice_id: notice_id, user_id: user_id)
      notice_user&.mark_as_read!
    end
    
    # Redirect to the notice page or app deep link
    redirect_url = params[:redirect_url] || notice_path(notice_id)
    redirect_to redirect_url
  end

  # POST /notices or /notices.json
  def create
    @notice = Notice.new(notice_params)
    respond_to do |format|
      if @notice.save
        if params[:notice][:user_ids].present?
          user_ids = params[:notice][:user_ids].split(',')
            user_ids.each do |user_id|
            NoticeUser.create(user_id: user_id , notice_id: @notice.id)
          end
        end
        @notice.notifying_users
        if params[:attachfiles].present? 
          params[:attachfiles].each do |doc|
            Attachfile.create(image: doc, relation: "NoticeImaage", relation_id: @notice.id, active: 1)
          end
        end

        if @notice.send_email.present?
         # binding.pry
          @notice.send_notice_notification
        end
        format.html { redirect_to @notice, notice: "Notice was successfully created." }
        format.json { render :show, status: :created, location: @notice }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @notice.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /notices/1 or /notices/1.json
  def update
    respond_to do |format|
      if @notice.update(notice_params)
        if params[:notice][:user_ids].present?
          user_ids = params[:notice][:user_ids].split(',')
            user_ids.each do |user_id|
            NoticeUser.find_or_initialize_by(user_id: user_id , notice_id: @notice.id)
          end
        end

        if params[:attachfiles].present? 
          params[:attachfiles].each do |doc|
            Attachfile.create(image: doc, relation: "NoticeImaage", relation_id: @notice.id, active: 1)
          end
        end
        format.html { redirect_to @notice, notice: "Notice was successfully updated." }
        format.json { render :show, status: :ok, location: @notice }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @notice.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /notices/1 or /notices/1.json
  def destroy
    @notice.destroy
    respond_to do |format|
      format.html { redirect_to notices_url, notice: "Notice was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_notice
      @notice = Notice.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def notice_params
      params.require(:notice).permit(:site_id, :enabled, :notice_title, :status, :send_email, :created_by_id, :notice_discription, :expiry_date,:shared, :group_id, :important)
    end
end
