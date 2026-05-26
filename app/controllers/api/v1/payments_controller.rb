module Api
  module V1
    class PaymentsController < ApplicationController
      include UserExt
      skip_before_action :verify_authenticity_token
      before_action :authenticate_user!, if: :check_user
      before_action :api_user
      before_action :set_user
      before_action :set_restaurant
      before_action :ensure_razorpay_enabled, except: [:webhook]

      # POST /api/v1/payments/create_order
      def create_order
        razorpay_order = razorpay_service.create_order(
          amount: params[:amount],
          receipt: "order_#{params[:order_id]}_#{Time.current.to_i}",
          currency: params[:currency] || 'INR'
        )

        render json: {
          razorpay_order_id: razorpay_order.id,
          razorpay_key: @restaurant.razorpay_key,
          amount: razorpay_order.amount,
          currency: razorpay_order.currency
        }
      rescue Razorpay::Error => e
        render json: { error: e.message }, status: :unprocessable_entity
      end

      # POST /api/v1/payments/verify
      def verify
        verified = razorpay_service.verify_payment(
          razorpay_order_id: params[:razorpay_order_id],
          razorpay_payment_id: params[:razorpay_payment_id],
          razorpay_signature: params[:razorpay_signature]
        )

        if verified
          payment = razorpay_service.fetch_payment(params[:razorpay_payment_id])

          if params[:order_id].present?
            order = RestaurantOrder.find_by(id: params[:order_id])
            if order
              order.update!(
                payment_status: 'Paid',
                razorpay_payment_id: params[:razorpay_payment_id],
                razorpay_order_id: params[:razorpay_order_id],
                paid_amount: payment.amount.to_f / 100,
                paid_at: Time.current
              )
            end
          end

          render json: {
            success: true,
            message: 'Payment verified successfully',
            payment_id: params[:razorpay_payment_id],
            order_id: params[:order_id],
            amount: payment.amount.to_f / 100
          }
        else
          render json: { error: 'Payment verification failed - signature mismatch' }, status: :unprocessable_entity
        end
      rescue Razorpay::Error => e
        render json: { error: e.message }, status: :unprocessable_entity
      end

      # POST /api/v1/payments/webhook
      skip_before_action :authenticate_user!, only: :webhook
      skip_before_action :ensure_razorpay_enabled, only: :webhook

      def webhook
        webhook_secret = @restaurant&.razorpay_secret || ENV['RAZORPAY_WEBHOOK_SECRET']
        payload = request.body.read
        received_signature = request.headers['X-Razorpay-Signature']

        expected_signature = OpenSSL::HMAC.hexdigest('SHA256', webhook_secret, payload)
        unless Rack::Utils.secure_compare(expected_signature, received_signature)
          return head :unauthorized
        end

        event = JSON.parse(payload)
        case event['event']
        when 'payment.captured'
          handle_payment_captured(event['payload']['payment']['entity'])
        when 'payment.failed'
          handle_payment_failed(event['payload']['payment']['entity'])
        when 'refund.created'
          handle_refund_created(event['payload']['refund']['entity'])
        end

        head :ok
      end

      private

      def set_restaurant
        restaurant_id = params[:restaurant_id].presence ||
                        (params[:order_id].presence && RestaurantOrder.find_by(id: params[:order_id])&.restaurant_id)
        @restaurant = FoodAndBeverage.find(restaurant_id) if restaurant_id
        render json: { error: 'Restaurant not found' }, status: :not_found unless @restaurant
      end

      def ensure_razorpay_enabled
        service = RazorpayService.new(@restaurant)
        render json: { error: 'Razorpay not enabled for this restaurant' }, status: :forbidden unless service.enabled?
      end

      def razorpay_service
        @razorpay_service ||= RazorpayService.new(@restaurant)
      end

      def handle_payment_captured(payment)
        order = RestaurantOrder.find_by(razorpay_order_id: payment['order_id'])
        return unless order

        order.update!(
          payment_status: 'Paid',
          razorpay_payment_id: payment['id'],
          paid_amount: payment['amount'].to_f / 100,
          paid_at: Time.zone.at(payment['created_at'])
        )
      end

      def handle_payment_failed(payment)
        order = RestaurantOrder.find_by(razorpay_order_id: payment['order_id'])
        return unless order

        order.update!(
          payment_status: 'Failed',
          payment_failure_reason: payment['error_description']
        )
      end

      def handle_refund_created(refund)
        order = RestaurantOrder.find_by(razorpay_payment_id: refund['payment_id'])
        return unless order

        order.update!(
          payment_status: 'Refunded',
          refund_amount: refund['amount'].to_f / 100,
          refunded_at: Time.zone.at(refund['created_at'])
        )
      end
    end
  end
end
