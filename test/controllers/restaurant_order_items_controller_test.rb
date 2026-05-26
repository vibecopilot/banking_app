require 'test_helper'

class RestaurantOrderItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @restaurant_order_item = restaurant_order_items(:one)
  end

  test "should get index" do
    get restaurant_order_items_url
    assert_response :success
  end

  test "should get new" do
    get new_restaurant_order_item_url
    assert_response :success
  end

  test "should create restaurant_order_item" do
    assert_difference('RestaurantOrderItem.count') do
      post restaurant_order_items_url, params: { restaurant_order_item: { amount: @restaurant_order_item.amount, order_id: @restaurant_order_item.order_id, quantity: @restaurant_order_item.quantity, rate: @restaurant_order_item.rate, restaurant_menu_id: @restaurant_order_item.restaurant_menu_id } }
    end

    assert_redirected_to restaurant_order_item_url(RestaurantOrderItem.last)
  end

  test "should show restaurant_order_item" do
    get restaurant_order_item_url(@restaurant_order_item)
    assert_response :success
  end

  test "should get edit" do
    get edit_restaurant_order_item_url(@restaurant_order_item)
    assert_response :success
  end

  test "should update restaurant_order_item" do
    patch restaurant_order_item_url(@restaurant_order_item), params: { restaurant_order_item: { amount: @restaurant_order_item.amount, order_id: @restaurant_order_item.order_id, quantity: @restaurant_order_item.quantity, rate: @restaurant_order_item.rate, restaurant_menu_id: @restaurant_order_item.restaurant_menu_id } }
    assert_redirected_to restaurant_order_item_url(@restaurant_order_item)
  end

  test "should destroy restaurant_order_item" do
    assert_difference('RestaurantOrderItem.count', -1) do
      delete restaurant_order_item_url(@restaurant_order_item)
    end

    assert_redirected_to restaurant_order_items_url
  end
end
