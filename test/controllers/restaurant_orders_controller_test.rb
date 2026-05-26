require 'test_helper'

class RestaurantOrdersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @restaurant_order = restaurant_orders(:one)
  end

  test "should get index" do
    get restaurant_orders_url
    assert_response :success
  end

  test "should get new" do
    get new_restaurant_order_url
    assert_response :success
  end

  test "should create restaurant_order" do
    assert_difference('RestaurantOrder.count') do
      post restaurant_orders_url, params: { restaurant_order: { ondate: @restaurant_order.ondate, ontime: @restaurant_order.ontime, payment_status: @restaurant_order.payment_status, restaurant_id: @restaurant_order.restaurant_id, status: @restaurant_order.status, total_amount: @restaurant_order.total_amount, user_id: @restaurant_order.user_id } }
    end

    assert_redirected_to restaurant_order_url(RestaurantOrder.last)
  end

  test "should show restaurant_order" do
    get restaurant_order_url(@restaurant_order)
    assert_response :success
  end

  test "should get edit" do
    get edit_restaurant_order_url(@restaurant_order)
    assert_response :success
  end

  test "should update restaurant_order" do
    patch restaurant_order_url(@restaurant_order), params: { restaurant_order: { ondate: @restaurant_order.ondate, ontime: @restaurant_order.ontime, payment_status: @restaurant_order.payment_status, restaurant_id: @restaurant_order.restaurant_id, status: @restaurant_order.status, total_amount: @restaurant_order.total_amount, user_id: @restaurant_order.user_id } }
    assert_redirected_to restaurant_order_url(@restaurant_order)
  end

  test "should destroy restaurant_order" do
    assert_difference('RestaurantOrder.count', -1) do
      delete restaurant_order_url(@restaurant_order)
    end

    assert_redirected_to restaurant_orders_url
  end
end
