module Api
  module V1
    class NotificationsController < ApplicationController
      include UserExt
      before_action :authenticate_user!, if: :check_user
      before_action :api_user
      before_action :set_user
      before_action :set_notification, only: [:mark_as_read, :destroy]

      # GET /api/v1/notifications/:id
      def show
        notification = @user.notifications.active.find_by(id: params[:id])
        return render json: { error: 'Notification not found' }, status: :not_found unless notification
        render json: serialize_notification(notification)
      end

      # GET /api/v1/notifications
      def index
        notifications = @user.notifications.active.order(created_at: :desc)

        notifications = case params[:status]
                        when 'read'   then notifications.read
                        when 'unread' then notifications.unread
                        else notifications
                        end

        notifications = notifications.where(notification_type: params[:type]) if params[:type].present?
        notifications = notifications.where(company_id: params[:company_id]) if params[:company_id].present?

        total_count  = notifications.count
        unread_count = @user.notifications.active.unread.count

        page     = (params[:page] || 1).to_i
        per_page = [[( params[:per_page] || 20).to_i, 1].max, 100].min
        offset   = (page - 1) * per_page

        notifications = notifications.limit(per_page).offset(offset)
        total_pages   = (total_count.to_f / per_page).ceil

        render json: {
          notifications: notifications.map { |n| serialize_notification(n) },
          pagination: {
            current_page: page,
            total_pages:  total_pages,
            total_count:  total_count,
            per_page:     per_page
          },
          unread_count: unread_count,
          total_count:  total_count
        }
      end

      # PATCH /api/v1/notifications/:id
      # Flexible update: pass read=true to mark as read, deleted=true to soft delete
      def update
        notification = @user.notifications.active.find_by(id: params[:id])
        return render json: { error: 'Notification not found' }, status: :not_found unless notification

        notification.mark_as_read! if params[:read].to_s == 'true' || params[:read_at].present?
        notification.soft_delete!  if params[:deleted].to_s == 'true'

        render json: serialize_notification(notification)
      end

      # PATCH/GET /api/v1/notifications/:id/mark_as_read
      def mark_as_read
        @notification.mark_as_read!
        render json: { id: @notification.id, read_at: @notification.read_at }
      end
      # PATCH/GET /api/v1/notifications/mark_all_as_read
      def mark_all_as_read
        scope = @user.notifications.active.unread
        scope = scope.where(notification_type: params[:type]) if params[:type].present?
        updated = scope.update_all(read_at: Time.current)
        render json: { updated_count: updated }
      end

      # DELETE /api/v1/notifications/:id
      def destroy
        @notification.soft_delete!
        render json: { id: @notification.id, deleted_at: @notification.deleted_at }
      end

      # GET /api/v1/notifications/unread_count
      def unread_count
        counts = @user.notifications.active.unread
                      .group(:notification_type)
                      .count

        render json: {
          unread_count: counts.values.sum,
          by_type:      counts
        }
      end

      private

      def set_notification
        @notification = @user.notifications.active.find_by(id: params[:id])
        render json: { error: 'Notification not found' }, status: :not_found unless @notification
      end

      def serialize_notification(n)
        {
          id:                n.id,
          title:             n.title,
          message:           n.message,
          notification_type: n.notification_type,
          notifiable_type:   n.notifiable_type,
          notifiable_id:     n.notifiable_id,
          record_id:         n.record_id,
          company_id:        n.company_id,
          read_at:           n.read_at,
          created_at:        n.created_at,
          metadata:          n.metadata || {}
        }
      end
    end
  end
end
