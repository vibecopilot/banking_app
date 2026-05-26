class EventsController < ApplicationController

  before_action :set_event, only: %i[ show edit update destroy ]
  include UserExt
  layout 'basic'
  before_action :set_user

  # GET /events or /events.json
  def index
    @events = Event.where(site_id: @user.current_site_id).ransack(params[:q]).result.order(created_at: :desc)
  end

  # GET /events/1 or /events/1.json
  def show
  end

  # GET /events/new
  def new
    @event = Event.new
  end

  # GET /events/1/edit
  def edit
  end

  # POST /events or /events.json
  def create
    @event = Event.new(event_params.merge(created_by: @user.id))
    respond_to do |format|
      if @event.save
        if params[:event][:user_ids].present?
          user_ids = params[:event][:user_ids].split(',')
          user_ids.each do |user_id|
            EventUser.create(user_id: user_id , event_id: @event.id)
          end
        end
        if params[:attachfiles].present?
          params[:attachfiles].each do |doc|
            Attachfile.create(image: doc, relation: "EventImaage", relation_id: @event.id, active: 1)
          end
        end
        if @event&.email_enabled?
          @event.send_event_notification
        end
        @event.create_qr
        format.html { redirect_to @event, notice: "Event was successfully created." }
        format.json { render :show, status: :created, location: @event }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end
  # PATCH/PUT /events/1 or /events/1.json
  def update
    respond_to do |format|
      if @event.update(event_params)
        if params[:event][:user_ids].present?
          user_ids = params[:event][:user_ids].split(',')
          user_ids.each do |user_id|
            EventUser.create(user_id: user_id , event_id: @event.id)
          end
        end
        if params[:attachfiles].present?
          params[:attachfiles].each do |doc|
            Attachfile.create(image: doc, relation: "EventImaage", relation_id: @event.id, active: 1)
          end
        end
        format.html { redirect_to @event, notice: "Event was successfully updated." }
        format.json { render :show, status: :ok, location: @event }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  def check_in
    @event = Event.find(params[:id])
    @event_user = @event.event_users.ransack(user_mobile_eq: params[:mobile]).result || @event.event_guests.ransack(mobile_eq: params[:mobile]).result

    if @event_user
      # Update check-in status and time
      @event_user.update(checked_in_at: Time.current, rsvp: 'attended')
      render json: { success: true, message: 'Successfully checked in' }
    else
      render json: { success: false, message: 'User not registered for this event' }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    render json: { success: false, message: 'Event not found' }, status: :not_found
  end

  # DELETE /events/1 or /events/1.json
  def destroy
    @event.destroy
    respond_to do |format|
      format.html { redirect_to events_url, notice: "Event was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  # Mark event as read for current user
  def mark_as_read
    event_user = EventUser.find_by(event_id: params[:id], user_id: @user.id)
    if event_user
      event_user.mark_as_read!
      render json: { success: true, message: "Event marked as read" }
    else
      render json: { success: false, message: "Event not found for user" }, status: :not_found
    end
  end

  # Mark event as archived for current user
  def mark_as_archived
    event_user = EventUser.find_by(event_id: params[:id], user_id: @user.id)
    if event_user
      event_user.mark_as_archived!
      render json: { success: true, message: "Event archived" }
    else
      render json: { success: false, message: "Event not found for user" }, status: :not_found
    end
  end

  # Track email open via tracking pixel (1x1 transparent image)
  def track_email_open
    event_id = params[:id]
    user_id = params[:user_id]

    if event_id.present? && user_id.present?
      event_user = EventUser.find_by(event_id: event_id, user_id: user_id)
      event_user&.mark_as_read!
    end

    # Return a 1x1 transparent GIF
    send_data Base64.decode64("R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7"),
      type: "image/gif",
      disposition: "inline"
  end

  # Track email link click - marks as read and redirects to event
  def track_email_click
    event_id = params[:id]
    user_id = params[:user_id]

    if event_id.present? && user_id.present?
      event_user = EventUser.find_by(event_id: event_id, user_id: user_id)
      event_user&.mark_as_read!
    end

    # Redirect to the event page or app deep link
    redirect_url = params[:redirect_url] || event_path(event_id)
    redirect_to redirect_url
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_event
    @event = Event.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def event_params
    params.require(:event).permit(:site_id, :enabled, :created_by,:event_name, :venue, :status ,:discription, :start_date_time, :end_date_time, :shared, :group_id, :email_enabled, :rsvp_enabled, :important)
  end
end
