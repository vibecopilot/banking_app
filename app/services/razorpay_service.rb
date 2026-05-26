class RazorpayService
  attr_reader :restaurant

  def initialize(restaurant)
    @restaurant = restaurant
    setup_client!
  end

  def enabled?
    restaurant.razorpay_enabled? &&
      restaurant.razorpay_key.present? &&
      restaurant.razorpay_secret.present?
  end

  def create_order(amount:, receipt: nil, currency: 'INR')
    Razorpay::Order.create(
      amount: (amount * 100).to_i,
      currency: currency,
      receipt: receipt || "order_#{Time.current.to_i}",
      notes: {
        restaurant_id: restaurant.id,
        restaurant_name: restaurant.restaurant_name
      }
    )
  end

  def verify_payment(razorpay_order_id:, razorpay_payment_id:, razorpay_signature:)
    expected_signature = OpenSSL::HMAC.hexdigest(
      'SHA256',
      restaurant.razorpay_secret,
      "#{razorpay_order_id}|#{razorpay_payment_id}"
    )
    expected_signature == razorpay_signature
  end

  def fetch_payment(payment_id)
    Razorpay::Payment.fetch(payment_id)
  end

  def capture_payment(payment_id, amount)
    Razorpay::Payment.capture(payment_id, amount: (amount * 100).to_i)
  end

  def refund(payment_id, amount: nil)
    payment = Razorpay::Payment.fetch(payment_id)
    options = {}
    options[:amount] = (amount * 100).to_i if amount
    payment.refund(options)
  end

  private

  def setup_client!
    Razorpay.setup(restaurant.razorpay_key, restaurant.razorpay_secret)
  end
end
