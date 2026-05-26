module Api
  module V1
    class MicrosoftController < ApplicationController
      include UserExt
      before_action :api_user
      before_action :ensure_microsoft_connected

      # GET /api/v1/microsoft/profile
      def profile
        data = graph.profile
        render json: data
      end

      # GET /api/v1/microsoft/calendar
      # Params: from (ISO8601), to (ISO8601)
      def calendar
        from = params[:from].present? ? Time.parse(params[:from]) : Time.current.beginning_of_day
        to   = params[:to].present?   ? Time.parse(params[:to])   : 7.days.from_now.end_of_day
        render json: graph.calendar_events(from: from, to: to)
      end

      # GET /api/v1/microsoft/holidays
      def holidays
        render json: graph.holidays
      end

      # GET /api/v1/microsoft/emails
      # Params: top (default 10)
      def emails
        top = (params[:top] || 10).to_i.clamp(1, 50)
        render json: graph.emails(top: top)
      end

      # GET /api/v1/microsoft/mailbox_settings
      def mailbox_settings
        render json: graph.mailbox_settings
      end

      private

      def graph
        @graph ||= MicrosoftGraphService.new(@user)
      end

      def ensure_microsoft_connected
        unless @user.microsoft_access_token.present?
          render json: {
            error:        'Microsoft account not connected',
            connect_url:  '/api/v1/auth/microsoft/init'
          }, status: :unprocessable_entity
        end
      end
    end
  end
end
